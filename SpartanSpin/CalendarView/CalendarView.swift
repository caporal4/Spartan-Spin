//
//  CalendarView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/18/25.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Colors.gradientC
                    .ignoresSafeArea()
                VStack {
                    Text("Calendar View Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.spartanSpinGreen)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Spartan Spin")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
