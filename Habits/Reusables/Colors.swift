//
//  Colors.swift
//  Habits
//
//  Created by Brendan Caporale on 3/3/25.
//

import Foundation
import SwiftUI

struct Colors {
    static let gradientA = LinearGradient(
        colors: [Color.white, Color.green],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientB = LinearGradient(
        colors: [Color.green, Color.gray],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientC = LinearGradient(
        stops: [
            Gradient.Stop(color: .green, location: Numbers.gradientCStopOne),
            Gradient.Stop(color: .white, location: Numbers.gradientCStopTwo)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
