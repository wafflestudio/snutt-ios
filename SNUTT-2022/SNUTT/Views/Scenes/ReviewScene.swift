//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

struct ReviewScene: View {
    // for test
    let viewModel: ReviewViewModel

    var body: some View {
        let _ = debugChanges()
    }
}

struct ReviewScene_Previews: PreviewProvider {
    static var previews: some View {
        ReviewScene(viewModel: .init(container: .preview))
    }
}
