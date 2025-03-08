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

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.coordinator.controller?.prepareEngine()
        }
        return view
    }

    /// Updates the presented `UIView` (and coordinator) to the latest configuration.
    func updateUIView(_: KMViewContainer, context: Self.Context) {
        if showMapView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                context.coordinator.controller?.activateEngine()
            }
        } else {
            context.coordinator.controller?.pauseEngine()
            context.coordinator.controller?.resetEngine()
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator($isMapNotInstalledAlertPresented, buildings: buildings, colorScheme: colorScheme)
    }

    /// Cleans up the presented `UIView` (and coordinator) in anticipation of their removal.
    static func dismantleUIView(_: KMViewContainer, coordinator _: KakaoMapCoordinator) {}

    class KakaoMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
        var controller: KMController?

        /// enumerated & sorted building locations (rightTop to leftBottom)
        private let buildings: EnumeratedSequence<[Dictionary<Location, String>.Element]>
        private var pois: [Poi: String] = [:]
        private let defaultPoint: Location

        private let colorScheme: ColorScheme
        @Binding var isMapNotInstalledAlertPresented: Bool

        init(_ isMapNotInstalledAlertPresented: Binding<Bool>,
             buildings: [Location: String],
             colorScheme: ColorScheme)
        {
            self.buildings = buildings
                .sorted { $0.key.latitude > $1.key.latitude || $0.key.longitude > $1.key.longitude }.enumerated()
            _isMapNotInstalledAlertPresented = isMapNotInstalledAlertPresented
            defaultPoint = .init(
                latitude: buildings.keys.reduce(Double(0)) { $0 + $1.latitude } / Double(buildings.count),
                longitude: buildings.keys.reduce(Double(0)) { $0 + $1.longitude } / Double(buildings.count)
            )
            self.colorScheme = colorScheme
            super.init()
        }

        private var mapView: KakaoMap? {
            controller?.getView("mapview") as? KakaoMap
        }

        private var locations: [Location] {
            buildings.map { $0.element.key }
        }

        private var shouldZoomOut: Bool {
            if buildings.reduce(0, { count, _ in count + 1 }) == 1 { return false }
            guard let location = locations.first else { return false }
            let latDistance = abs(location.latitude.distance(to: defaultPoint.latitude))
            let lngDistance = abs(location.longitude.distance(to: defaultPoint.longitude))
            return latDistance > 0.002 || lngDistance > 0.002
        }

        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        /// automatically called after running startEngine() and preparing for view rendering
        func addViews() {
            let defaultPosition = MapPoint(longitude: defaultPoint.longitude, latitude: defaultPoint.latitude)
            let mapviewInfo = MapviewInfo(
                viewName: "mapview",
                viewInfoName: "map",
                defaultPosition: defaultPosition,
                defaultLevel: shouldZoomOut ? 14 : 15
            )
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_: String, viewInfoName _: String) {
            guard let mapView = mapView else {
                return
            }
            mapView.eventDelegate = self

            if colorScheme == .light {
                mapView.dimScreen.color = .init(white: 0, alpha: 0.4)
            } else {
                mapView.dimScreen.color = .init(white: 0, alpha: 0.15)
            }
            mapView.dimScreen.cover = .map

            disableAllGestures(mapView)
            createLabelLayer()
            createPoiStyle()
            createPois()
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
            guard let mapView = mapView else { return }
            mapView.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        }

        private func createLabelLayer() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()

            // layer for blur-effect background
            let blurLayerOption = LabelLayerOptions(
                layerID: "blurBackground",
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 1000
            )
            let _ = manager.addLabelLayer(option: blurLayerOption)

            for building in buildings {
                let layerOption = LabelLayerOptions(
                    layerID: "poi\(building.offset)",
                    competitionType: .none,
                    competitionUnit: .symbolFirst,
                    orderType: .rank,
                    zOrder: 1100 + building.offset
                )
                let _ = manager.addLabelLayer(option: layerOption)
            }
        }

        private func createPoiStyle() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()

            // blur
            let blurIconStyle = PoiIconStyle(symbol: UIImage(named: "map.blur.background"))
            let blurPoiStyle = PoiStyle(styleID: "blur", styles: [
                PerLevelPoiStyle(iconStyle: blurIconStyle, level: 0),
            ])

            // not focused
            let notFocusedIconStyle = PoiIconStyle(symbol: UIImage(named: "map.pin"))
            let notFocusedTextStyle = TextStyle(
                fontSize: 24,
                fontColor: .black,
                strokeThickness: 2,
                strokeColor: .white
            )
            let poiNotFocusedTextStyle = PoiTextStyle(textLineStyles: [
                PoiTextLineStyle(textStyle: notFocusedTextStyle),
            ])
            let notFocusedPoiStyle = PoiStyle(styleID: "notFocused", styles: [
                PerLevelPoiStyle(iconStyle: notFocusedIconStyle, textStyle: poiNotFocusedTextStyle, level: 0),
            ])

            // focused(dim)
            let focusedIconStyle = PoiIconStyle(symbol: UIImage(named: "map.pin.dim"))
            let focusedTextStyle = TextStyle(
                fontSize: 26,
                fontColor: .white,
                strokeThickness: 1,
                strokeColor: .init(.init(hex: "#8A8A8A"))
            )
            let poiFocusedTextStyle = PoiTextStyle(textLineStyles: [
                PoiTextLineStyle(textStyle: focusedTextStyle),
            ])
            let focusedPoiStyle = PoiStyle(styleID: "focused", styles: [
                PerLevelPoiStyle(iconStyle: focusedIconStyle, textStyle: poiFocusedTextStyle, level: 0),
            ])

            manager.addPoiStyle(blurPoiStyle)
            manager.addPoiStyle(notFocusedPoiStyle)
            manager.addPoiStyle(focusedPoiStyle)
        }

        private func createPois() {
            guard let mapView = mapView else { return }
            let manager = mapView.getLabelManager()
            var poiOptionList: [PoiOptions] = []

            // blur
            let blurPoiOption = PoiOptions(styleID: "blur")
            blurPoiOption.rank = 0
            blurPoiOption.clickable = true
            let blurLayer = manager.getLabelLayer(layerID: "blurBackground")

            // marker
            for building in buildings {
                let markerPoiOption = PoiOptions(styleID: "notFocused")
                markerPoiOption.rank = 0
                markerPoiOption.clickable = true
                markerPoiOption.addText(PoiText(text: building.element.value, styleIndex: 0))
                poiOptionList.append(markerPoiOption)

                let markerLayer = manager.getLabelLayer(layerID: "poi\(building.offset)")
                if let blurPoi = blurLayer?.addPoi(option: blurPoiOption,
                                                   at: .init(longitude: building.element.key.longitude,
                                                             latitude: building.element.key.latitude - 0.0007))
                {
                    blurPoi.show()
                }

                if let markerPoi = markerLayer?.addPoi(option: poiOptionList[building.offset],
                                                       at: .init(longitude: building.element.key.longitude,
                                                                 latitude: building.element.key.latitude))
                {
                    pois[markerPoi] = building.element.value
                    markerPoi.show()
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

            // blur
            let blurLayer = manager.getLabelLayer(layerID: "blurBackground")
            mapView.dimScreen.isEnabled ? blurLayer?.hideAllPois() : blurLayer?.showAllPois()

            // marker
            for building in buildings {
                let layer = manager.getLabelLayer(layerID: "poi\(building.offset)")
                layer?.getAllPois()?
                    .forEach { $0.changeStyle(styleID: mapView.dimScreen.isEnabled ? "focused" : "notFocused") }
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
            let urlString =
                "nmap://place?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&name=\(label)&appname=" + bundleID
            guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedString) else { return nil }
            return url
        }

        private func kakaoMapURL(coordinate: GeoCoordinate) -> URL? {
            guard let url = URL(string: "kakaomap://look?p=\(coordinate.latitude),\(coordinate.longitude)")
            else { return nil }
            return url
        }
    }
}
