//
//  KakaoMapView.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/26.
//

import KakaoMapsSDK
import SwiftUI

struct KakaoMapView: UIViewRepresentable {
    @Binding var showMapView: Bool
    @Binding var isMapNotInstalledAlertPresented: Bool
    let colorScheme: ColorScheme
    let buildings: [Location: String]

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
            if showMapView {
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
    static func dismantleUIView(_: KMViewContainer, coordinator: KakaoMapCoordinator) {
        coordinator.controller?.stopRendering()
        coordinator.controller?.stopEngine()
    }

    class KakaoMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
        var controller: KMController?
        private var isFirstOpen: Bool = true

        /// enumerated & sorted building locations (rightTop to leftBottom)
        private let buildings: EnumeratedSequence<[Dictionary<Location, String>.Element]>
        private var pois: [Poi: String] = [:]
        private let defaultPoint: Location

        private let colorScheme: ColorScheme
        @Binding var isMapNotInstalledAlertPresented: Bool

        init(_ isMapNotInstalledAlertPresented: Binding<Bool>, 
             buildings: [Location: String],
             colorScheme: ColorScheme) {
            self.buildings = buildings.sorted { $0.key.latitude > $1.key.latitude || $0.key.longitude > $1.key.longitude }.enumerated()
            _isMapNotInstalledAlertPresented = isMapNotInstalledAlertPresented
            defaultPoint = .init(latitude: buildings.keys.reduce(Double(0)) { $0 + $1.latitude } / Double(buildings.count),
                                 longitude: buildings.keys.reduce(Double(0)) { $0 + $1.longitude } / Double(buildings.count))
            self.colorScheme = colorScheme
            super.init()
        }

        private var mapView: KakaoMap? {
            controller?.getView("mapview") as? KakaoMap
        }

        private var locations: [Location] {
            buildings.map { $0.element.key }
        }

        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        /// automatically called after running startEngine() and preparing for view rendering
        func addViews() {
            let defaultPosition = MapPoint(longitude: defaultPoint.longitude, latitude: defaultPoint.latitude)
            let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 15)

            if controller?.addView(mapviewInfo) == Result.OK {
                guard let mapView = mapView else {
                    return
                }
                mapView.eventDelegate = self
                mapView.setMargins(.init(top: 24, left: 24, bottom: 48, right: 24))
                
                mapView.setLogoPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .right), position: CGPoint(x: -12.0, y: -36.0))

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

        func poiDidTapped(kakaoMap _: KakaoMap, layerID: String, poiID: String, position _: MapPoint) {
            if layerID == "place" {
                toggleDimScreen()
                return
            }
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            let poi = manager.getLabelLayer(layerID: layerID)?.getPoi(poiID: poiID)
            if let coordinate = poi?.position.wgsCoord,
               let matchingPoi = pois.first(where: { $0.key == poi })
            {
                openInExternalApp(coordinate: coordinate, label: matchingPoi.value)
            }
        }
        
        /// KMViewContainer 리사이징 될 때 호출.
        func containerDidResized(_ size: CGSize) {
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if isFirstOpen {
                let cameraUpdate: CameraUpdate = .make(target: MapPoint(longitude: defaultPoint.longitude, latitude: defaultPoint.latitude), zoomLevel: 15, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                isFirstOpen = false
            }
        }

        private func createLabelLayer() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            buildings.forEach { building in
                let layerOption = LabelLayerOptions(layerID: "poi\(building.offset)", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1000 + building.offset)
                let _ = manager.addLabelLayer(option: layerOption)
            }
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
            var poiOptionList: [PoiOptions] = []

            buildings.forEach { building in
                let poiOption = PoiOptions(styleID: "notFocused")
                poiOption.rank = 0
                poiOption.clickable = true
                poiOption.addText(PoiText(text: building.element.value, styleIndex: 0))
                poiOptionList.append(poiOption)

                let layer = manager.getLabelLayer(layerID: "poi\(building.offset)")
                if let poi = layer?.addPoi(option: poiOptionList[building.offset],
                                           at: .init(longitude: building.element.key.longitude,
                                                     latitude: building.element.key.latitude))
                {
                    pois[poi] = building.element.value
                    poi.show()
                }
            }

            if shouldResizeCamera() {
                let cameraUpdate = CameraUpdate.make(area: AreaRect(points: locations.map { .init(longitude: $0.longitude, latitude: $0.latitude) }))
                DispatchQueue.main.async {
                    mapView.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 2000))
                }
            }
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
            mapView.dimScreen.isEnabled.toggle()
            buildings.forEach { building in
                let layer = manager.getLabelLayer(layerID: "poi\(building.offset)")
                layer?.getAllPois()?.forEach { $0.changeStyle(styleID: mapView.dimScreen.isEnabled ? "focused" : "notFocused") }
            }
        }

        private func openInExternalApp(coordinate: GeoCoordinate, label: String?) {
            guard let naverMapURL = naverMapURL(coordinate: coordinate, label: label) else { return }
            guard let kakaoMapURL = kakaoMapURL(coordinate: coordinate) else { return }
            if UIApplication.shared.canOpenURL(naverMapURL) {
                UIApplication.shared.open(naverMapURL)
            } else if UIApplication.shared.canOpenURL(kakaoMapURL) {
                UIApplication.shared.open(kakaoMapURL)
            } else {
                isMapNotInstalledAlertPresented = true
            }
        }

        private func naverMapURL(coordinate: GeoCoordinate, label: String?) -> URL? {
            guard let label = label else { return nil }
            let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
            let urlString = "nmap://place?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&name=\(label)&appname=" + bundleID
            guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedString) else { return nil }
            return url
        }

        private func kakaoMapURL(coordinate: GeoCoordinate) -> URL? {
            guard let url = URL(string: "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)") else { return nil }
            return url
        }

        private func shouldResizeCamera() -> Bool {
            if pois.count == 1 { return false }
            guard let location = locations.first else { return false }
            let latDistance = location.latitude.distance(to: defaultPoint.latitude)
            let lngDistance = location.longitude.distance(to: defaultPoint.longitude)
            return latDistance > 0.002 || lngDistance > 0.002
        }
    }
}
