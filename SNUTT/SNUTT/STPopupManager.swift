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
    static var popupList: [STPopup] = []
    
    /// STPopupManager을 초기화합니다.
    /// 반드시 UserDefaults에 저장된 데이터를 먼저 불러옵니다.
    static func initialize() {
        STPopupManager.loadData()
        STPopupManager.getRecentPopup()
        print("popupList(initialize): \(popupList)")
    }
    
    /// 현재 popupList를 UserDefaults에 저장합니다.
    static func saveData() {
        let dictList = STPopupManager.toDictionary()
        STDefaults[.popupList] = dictList
    }
    
    /// 서버에서 최신 팝업 정보를 받아옵니다.
    private static func getRecentPopup() {
        STNetworking.getPopups { popups in
            for pop in popups {
                if !popupList.contains(pop) {
                    print("새롭게 추가할 팝업입니다. \(pop)")
                    popupList.append(pop)
                }
                #if DEBUG
                print(pop)
                #endif
            }
            filterData()
            print("popupList(after filter): \(popupList)")
            saveData()
            print("popupList(after save): \(popupList)")
        } failure: {}
    }
    
    /// UserDefaults에 저장된 팝업 정보를 불러옵니다.
    static func loadData() {
        print("불러온 데이터를 출력합니다.")
        if let dict = STDefaults[.popupList] {
            for data in dict {
                guard let popup = STPopup(dictionary: data) else { continue }
                print(popup)
                if !popupList.contains(popup) {
                    popupList.append(popup)
                }
            }
        }
        print("불러온 데이터 출력 완료")
    }
    
    /// 마지막으로 "닫기"를 누른 시점을 저장합니다.
    static func saveLastUpdate(for popup: STPopup?) {
        guard let popup = popup else {
            return
        }
        popupList.indices.filter {
            popupList[$0] == popup
        }.forEach {
            popupList[$0].lastUpdate = Date()
        }
        saveData()
    }
    
    /// 유저에게 보여야 하는 팝업만 남깁니다.
    private static func filterData() {
        popupList = popupList.filter({ popup in
            print("이 팝업을 띄워야 할까요?: \(shouldShow(popup: popup))")
            return shouldShow(popup: popup)
        })
    }
    
    /// 유저에게 보여야 하는 팝업인지 판단합니다.
    private static func shouldShow(popup: STPopup) -> Bool {
        guard let lastUpdate = popup.lastUpdate else {
            return true
        }
        print("\(Date().daysFrom(lastUpdate)) > \(popup.hiddenDays)")
        return Date().daysFrom(lastUpdate) > popup.hiddenDays ?? 0
    }
    
    private static func toDictionary() -> [NSDictionary]? {
        if popupList.isEmpty { return nil }
        return popupList.dictionaryValue()
    }
}
