//
//  SystemState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI
import UIKit

@MainActor
class SystemState {
    @Published var isErrorAlertPresented = false
    @Published var error: STError? = nil

    /// The property stores the color scheme that the user has set as their preference.
    /// If `nil`, the system appearance will be used.
    @Published var preferredColorScheme: ColorScheme? = nil

    @Published var selectedTab: TabType = .timetable
    
    @Published var toast: ToastType? = nil
    @Published var toastButtonAction: (() -> Void)? = nil

    @Published var noticeViewInfo: ConfigsDto.NoticeViewInfoDto?

    var isMapViewExpanded: Bool?
    var configs: ConfigsDto?
}

enum ToastType {
    case bookmark
    case reminderNone
    case reminder10Before
    case reminder10After
    case reminderOnTime
    case vacancy
    
    var message: String {
        switch self {
        case .bookmark: "관심강좌가 등록되었습니다."
        case .reminderNone: "전자출결 알림이 해제되었습니다."
        case .reminder10Before: "수업 시작 10분 전에 푸시알림을 보내드립니다."
        case .reminder10After: "수업 시작 10분 후에 푸시알림을 보내드립니다."
        case .reminderOnTime: "수업이 시작하면 푸시 알림을 보내드립니다."
        case .vacancy: "빈자리 알림이 설정되었습니다."
        }
    }
    
    // FIXME: "보기" 버튼 활성화 여부는 디자이너 상의 후 확정
    
    var showButton: Bool {
        switch self {
        case .reminderNone,
             .reminder10Before,
             .reminder10After,
             .reminderOnTime:
            return true
        default:
            return false
        }
    }
}
