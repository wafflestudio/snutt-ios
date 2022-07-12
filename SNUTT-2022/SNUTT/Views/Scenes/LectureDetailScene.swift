//
//  LectureDetailScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct LectureDetailScene: View {
    let viewModel: ViewModel

    var body: some View {
        Text("This is LectureDetails View.")
    }
}

extension LectureDetailScene {
    class ViewModel: BaseViewModel {}
}

struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        LectureDetailScene(viewModel: .init(container: .preview))
    }
}
