//
//  KakaoMapView.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/26.
//

import KakaoMapsSDK
import SwiftUI

struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var isMapNotInstalledAlertPresented: Bool
    let colorScheme: ColorScheme
    let buildings: [Location: String]

    /// UIView를 상속한 KMViewContainer를 생성한다.
    /// 뷰 생성과 함께 KMControllerDelegate를 구현한 Coordinator를 생성하고, 엔진을 생성 및 초기화한다.
    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        context.coordinator.controller?.initEngine()
        return view
    }

    /// Updates the presented `UIView` (and coordinator) to the latest configuration.
    func updateUIView(_: KMViewContainer, context: Self.Context) {
        DispatchQueue.main.async {
            if draw {
                context.coordinator.controller?.startEngine()
                context.coordinator.controller?.startRendering()
            } else {
                context.coordinator.controller?.stopRendering()
                context.coordinator.controller?.stopEngine()
            }
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator($isMapNotInstalledAlertPresented, buildings: buildings, colorScheme: colorScheme)
    }

    /// Cleans up the presented `UIView` (and coordinator) in anticipation of their removal.
    static func dismantleUIView(_: KMViewContainer, coordinator _: KakaoMapCoordinator) {}

    /// Coordinator 구현. KMControllerDelegate를 adopt한다.
    class KakaoMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
        var controller: KMController?
        var first: Bool
        let buildings: [Location: String]
        var pois: [Poi] = []
        let defaultPoint: Location

        let colorScheme: ColorScheme
        @Binding var isMapNotInstalledAlertPresented: Bool

        init(_ isMapNotInstalledAlertPresented: Binding<Bool>, buildings: [Location: String], colorScheme: ColorScheme) {
            self.buildings = buildings
            first = true
            _isMapNotInstalledAlertPresented = isMapNotInstalledAlertPresented
            defaultPoint = .init(latitude: buildings.keys.reduce(Double(0)) { $0 + $1.latitude } / Double(buildings.count),
                                 longitude: buildings.keys.reduce(Double(0)) { $0 + $1.longitude } / Double(buildings.count))
            self.colorScheme = colorScheme
            super.init()
        }

        var mapView: KakaoMap? {
            controller?.getView("mapview") as? KakaoMap
        }

        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        /// 엔진 생성 및 초기화 이후, 렌더링 준비가 완료되면 아래 addViews를 호출한다.
        func addViews() {
            let defaultPosition = MapPoint(longitude: defaultPoint.longitude, latitude: defaultPoint.latitude)
            let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 16)

            if controller?.addView(mapviewInfo) == Result.OK {
                guard let mapView = mapView else {
                    return
                }
                mapView.eventDelegate = self

                if colorScheme == .light {
                    mapView.dimScreen.color = UIColor(white: 0, alpha: 0.4)
                } else {
                    mapView.dimScreen.color = UIColor(white: 0, alpha: 0.15)
                }
                mapView.dimScreen.cover = .map

                disableAllGestures(mapView)
                createLabelLayer()
                createPoiStyle()
                createPois()
            }
        }

        func terrainDidTapped(kakaoMap _: KakaoMap, position _: MapPoint) {
            toggleDimScreen()
        }

        func poiDidTapped(kakaoMap _: KakaoMap, layerID _: String, poiID: String, position _: MapPoint) {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            let poi = manager.getLabelLayer(layerID: "poi")?.getPoi(poiID: poiID)
            if let coordinate = poi?.position.wgsCoord {
                openInExternalApp(coordinate: coordinate)
            }
        }

        /// KMViewContainer 리사이징 될 때 호출.
        func containerDidResized(_ size: CGSize) {
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate: CameraUpdate = .make(target: MapPoint(longitude: defaultPoint.longitude, latitude: defaultPoint.latitude), zoomLevel: 16, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }

        private func createLabelLayer() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            let layerOption = LabelLayerOptions(layerID: "poi", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1000)
            let _ = manager.addLabelLayer(option: layerOption)
        }

        private func createPoiStyle() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            
            // not focused
            let notFocusedIconStyle = PoiIconStyle(symbol: UIImage(named: "map.pin"))
            let notFocusedTextStyle = TextStyle(fontSize: 24, fontColor: .black, strokeThickness: 2, strokeColor: .white)
            let poiNotFocusedTextStyle = PoiTextStyle(textLineStyles: [
                PoiTextLineStyle(textStyle: notFocusedTextStyle),
            ])
            let notFocusedPoiStyle = PoiStyle(styleID: "notFocused", styles: [
                PerLevelPoiStyle(iconStyle: notFocusedIconStyle, textStyle: poiNotFocusedTextStyle, level: 0),
            ])
            
            // focused(dim)
            let focusedIconStyle = PoiIconStyle(symbol: UIImage(named: "map.pin.dim"))
            let focusedTextStyle = TextStyle(fontSize: 26, fontColor: .white, strokeThickness: 1, strokeColor: .init(.init(hex: "#8A8A8A")))
            let poiFocusedTextStyle = PoiTextStyle(textLineStyles: [
                PoiTextLineStyle(textStyle: focusedTextStyle),
            ])
            let focusedPoiStyle = PoiStyle(styleID: "focused", styles: [
                PerLevelPoiStyle(iconStyle: focusedIconStyle, textStyle: poiFocusedTextStyle, level: 0),
            ])
            
            manager.addPoiStyle(notFocusedPoiStyle)
            manager.addPoiStyle(focusedPoiStyle)
        }

        private func createPois() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "poi")
            var poiOptionList: [PoiOptions] = []

            buildings.forEach {
                let poiOption = PoiOptions(styleID: "notFocused")
                poiOption.rank = 0
                poiOption.clickable = true
                poiOption.addText(PoiText(text: $0.value, styleIndex: 0))
                poiOptionList.append(poiOption)
            }

            pois = layer?.addPois(options: poiOptionList, at: buildings.keys.map { .init(longitude: $0.longitude, latitude: $0.latitude) }) ?? []
            let _ = pois.map { $0.show() }
        }

        private func disableAllGestures(_ mapView: KakaoMap) {
            mapView.setGestureEnable(type: .doubleTapZoomIn, enable: false)
            mapView.setGestureEnable(type: .longTapAndDrag, enable: false)
            mapView.setGestureEnable(type: .oneFingerZoom, enable: false)
            mapView.setGestureEnable(type: .pan, enable: false)
            mapView.setGestureEnable(type: .rotate, enable: false)
            mapView.setGestureEnable(type: .rotateZoom, enable: false)
            mapView.setGestureEnable(type: .tilt, enable: false)
            mapView.setGestureEnable(type: .twoFingerTapZoomOut, enable: false)
            mapView.setGestureEnable(type: .zoom, enable: false)
        }

        private func toggleDimScreen() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "poi")
            let pois = layer?.getAllPois()
            
            mapView.dimScreen.isEnabled.toggle()
            pois?.forEach { $0.changeStyle(styleID: mapView.dimScreen.isEnabled ? "focused" : "notFocused") }
        }

        func openInExternalApp(coordinate: GeoCoordinate) {
            guard let naverMapURL = naverMapURL(coordinate: coordinate) else { return }
            guard let kakaoMapURL = kakaoMapURL(coordinate: coordinate) else { return }
            if UIApplication.shared.canOpenURL(naverMapURL) {
                UIApplication.shared.open(naverMapURL)
            } else if UIApplication.shared.canOpenURL(kakaoMapURL) {
                UIApplication.shared.open(kakaoMapURL)
            } else {
                isMapNotInstalledAlertPresented = true
            }
        }

        private func naverMapURL(coordinate: GeoCoordinate) -> URL? {
            let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
            guard let url = URL(string: "nmap://map?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&zoom=17&appname=" + bundleID) else { return nil }
            return url
        }

        private func kakaoMapURL(coordinate: GeoCoordinate) -> URL? {
            guard let url = URL(string: "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)") else { return nil }
            return url
        }
    }
}
