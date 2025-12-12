//
//  MonthlyMoveButton.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/2/25.
//

import SwiftUI

struct MonthlyMoveButton: View {
    let monthlyMove: String?
    let failedToLoad: Bool
    let count: Int? // Count refers to the number of goals that match the monthly move
    let phrases = [
        "Tap here to add as a goal",
        "Tap here to view goal",
        "Tap here to view goals"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                if failedToLoad {
                    Text("Failed to load Move of the Month")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.spartanSpinGreen)
                        .tracking(1)
                    
                    Text("Tap here to try again")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.spartanSpinGreen)
                        .tracking(1)
                } else {
                    Text("MOVE OF THE MONTH")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.spartanSpinGreen)
                        .tracking(1)
                    
                    if let monthlyMove {
                        Text(monthlyMove)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                    if let count = count {
                        Text(phrases[calculatePhrase(count)])
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.spartanSpinGreen)
                            .tracking(1)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    private func calculatePhrase(_ int: Int) -> Int {
        if int == 0 {
            return int
        } else if int == 1 {
            return int
        } else {
            return 2
        }
    }
}

#Preview {
    MonthlyMoveButton(monthlyMove: "Push-ups", failedToLoad: false, count: 1)
}
