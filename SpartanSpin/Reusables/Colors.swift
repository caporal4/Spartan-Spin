//
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation
import SwiftUI

struct Colors {
    static let spartanSpinGreen = Color(red: 0.0/255.0, green: 133.0/255.0, blue: 62.0/255.0)
    
    static let gradientA = LinearGradient(
        colors: [Color.white, Colors.spartanSpinGreen],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientC = LinearGradient(
        stops: [
//            Gradient.Stop(color: .white, location: Numbers.gradientCStopOne),
            Gradient.Stop(
                color: Colors.spartanSpinGreen.opacity(Numbers.gradientCOpacity),
                location: Numbers.gradientCStopTwo
            ),
            Gradient.Stop(color: Colors.spartanSpinGreen, location: Numbers.gradientCStopThree)

        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
