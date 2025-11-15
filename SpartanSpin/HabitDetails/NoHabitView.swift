//
//  NoHabitView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct NoHabitView: View {
    var body: some View {
        ZStack {
            Colors.spartanSpinGreen
                .ignoresSafeArea()
            Text("No Habit Selected")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NoHabitView()
}
