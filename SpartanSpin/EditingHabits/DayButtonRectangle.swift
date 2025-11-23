//
//  DayButtonRectangle.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/22/25.
//

import SwiftUI

struct DayButtonRectangle: View {
    let day: String
    let daySelected: Bool
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: Numbers.dayButtonCornerRadius)
                    .frame(
                        width: Numbers.dayButtonWidth,
                        height: Numbers.dayButtonHeight,
                        alignment: .leading
                    )
                    .foregroundStyle(daySelected ? Color.blue : Color.gray.opacity(Numbers.dayButtonForegroundOpacity))
                Text(day)
                    .font(.system(size: Numbers.dayButtonFontSize))
                    .foregroundColor(daySelected ? .white : .primary)
            }
    }
    init(day: String, daySelected: Bool) {
        self.day = day
        self.daySelected = daySelected
    }
}

#Preview {
    let day = "Mon"
    DayButtonRectangle(day: day, daySelected: true)
}
