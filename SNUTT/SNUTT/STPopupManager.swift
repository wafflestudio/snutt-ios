//
//  STPopupManager.swift
//  SNUTT
//
//  Created by 최유림 on 2022/07/11.
//  Copyright © 2022 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STPopupManager {
    /// 유저에게 보여줄 팝업 리스트입니다.
    static var popupList: [STPopup] {
        STPopupManager.filterPopup()
    }

    /// 유저에게 보여주지 않을 팝업까지 포함된 전체 리스트입니다.
    private static var totalPopupList: [STPopup] = []

    /// 서버에서 받아온 팝업
    private static var serverPopupList: [STPopup] = []

    static var hasShownPopup: Bool = false

    /// STPopupManager을 초기화합니다.
    static func initialize(then: @escaping () -> Void) {
        STPopupManager.hasShownPopup = false
        STPopupManager.getRecentPopup(then: then)
    }

    /// 현재 popupList를 UserDefaults에 저장합니다.
    static func saveData() {
        let dictList = STPopupManager.toDictionary()
        STDefaults[.popupList] = dictList
    }

    /// 마지막으로 "닫기"를 누른 시점을 저장합니다.
    static func saveLastUpdate(for popup: STPopup?) {
        guard let popup = popup else {
            return
        }
        totalPopupList.indices.filter {
            totalPopupList[$0] == popup
        }.forEach {
            totalPopupList[$0].lastUpdate = Date()
        }
        saveData()
    }

    /// UserDefaults에 저장된 팝업 정보를 불러옵니다.
    private static func loadData() {
        if let dict = STDefaults[.popupList] {
            for data in dict {
                guard let popup = STPopup(dictionary: data) else { continue }
                #if DEBUG
                    print(popup)
                #endif
                totalPopupList.indices.filter {
                    totalPopupList[$0] == popup
                }.forEach {
                    totalPopupList[$0] = popup
                }
            }
        }
    }

    /// 서버에서 최신 팝업 정보를 받아옵니다.
    private static func getRecentPopup(then: @escaping () -> Void) {
        totalPopupList.removeAll()
        STNetworking.getPopups { popups in
            for popup in popups {
                #if DEBUG
                    print(popup)
                #endif
                totalPopupList.append(popup)
            }
            loadData()
            then()
            saveData()
        } failure: {
            saveData()
        }
    }

    /// 유저에게 보여야 하는 팝업만 남겨 반환합니다.
    private static func filterPopup() -> [STPopup] {
        return totalPopupList.filter { popup in
            shouldShow(popup: popup)
        }
    }

    /// 유저에게 보여야 하는 팝업인지 판단합니다.
    private static func shouldShow(popup: STPopup) -> Bool {
        guard let lastUpdate = popup.lastUpdate else {
            return true
        }
        return Date().daysFrom(lastUpdate) > popup.hiddenDays ?? 0
    }

    private static func toDictionary() -> [NSDictionary]? {
        if totalPopupList.isEmpty { return nil }
        return totalPopupList.dictionaryValue()
    }
}
