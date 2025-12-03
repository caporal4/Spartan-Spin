//
//  MonthlyMoveButton.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/2/25.
//

import SwiftUI

struct MonthlyMoveButton: View {
    let monthlyMove: String
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("MOVE OF THE MONTH")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.spartanSpinGreen)
                    .tracking(1)
                
                Text(monthlyMove)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Tap here to add as a goal")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.spartanSpinGreen)
                    .tracking(1)
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
}

#Preview {
    MonthlyMoveButton(monthlyMove: "Push-ups")
}
