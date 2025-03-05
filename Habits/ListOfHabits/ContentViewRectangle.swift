//
//  ContentViewRectangle.swift
//  Habits
//
//  Created by Brendan Caporale on 3/4/25.
//

import SwiftUI

struct ContentViewRectangle: View {
    var body: some View {
        Rectangle()
            .frame(
                width: Numbers.sizingRectangleWidth,
                height: Numbers.sizingRectangleHeight,
                alignment: .leading
            )
            .foregroundStyle(.clear)
    }
}

#Preview {
    ContentViewRectangle()
}
