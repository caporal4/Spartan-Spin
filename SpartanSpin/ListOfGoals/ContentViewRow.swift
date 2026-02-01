//
//  ContentViewRow.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct ContentViewRow: View {    
    @ObservedObject var goal: Goal
    
    var body: some View {
        HStack {
            VStack {
                Text(goal.goalTitle)
                    .font(.system(
                        size: Numbers.goalTitleFontSize,
                        weight: .bold,
                        design: .default)
                    )
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Progress:")
                    .font(.headline)
                    .foregroundStyle(.white)
                HStack {
                    Text(LocalizedStringKey(goal.createFraction()))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    ContentViewRow(goal: Goal.example(controller: persistenceController))
        .background(Colors.spartanSpinGreen)
        .environmentObject(persistenceController)
}
