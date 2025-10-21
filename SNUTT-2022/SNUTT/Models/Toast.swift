//
//  Toast.swift
//  SNUTT
//
//  Created by 최유림 on 9/3/25.
//

import Foundation

struct Toast: Identifiable {
    let id = UUID()
    let type: ToastType
    var action: () -> Void = {}
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
        case .bookmark: "검색탭 우측 상단에서 관심강좌 목록을 확인해보세요."
        case .reminderNone: "전자출결 알림이 해제되었습니다."
        case .reminder10Before: "수업 시작 10분 전에 푸시 알림을 보내드립니다."
        case .reminder10After: "수업 시작 10분 후에 푸시 알림을 보내드립니다."
        case .reminderOnTime: "수업이 시작하면 푸시 알림을 보내드립니다."
        case .vacancy: "더보기탭에서 빈자리 알림 목록을 확인해보세요."
        }
    }
}
