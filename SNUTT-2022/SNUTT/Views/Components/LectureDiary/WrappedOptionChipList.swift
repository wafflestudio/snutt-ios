//
//  WrappedOptionChipList.swift
//  SNUTT
//
//  Created by 최유림 on 11/4/25.
//

import SwiftUI

struct WrappedOptionChipList: View {
    
    @Binding var selectedOptions: [AnswerOption]
    let answerOptions: [AnswerOption]
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ForEach(answerOptions, id: \.id) { label in
            
        }
    }
}
