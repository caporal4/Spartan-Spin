//
//  UIApplicationExtension.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/25/25.
//

import Foundation
import SwiftUI

extension UIApplication {
    static var notificationSettingsURL: URL? {
        URL(string: UIApplication.openNotificationSettingsURLString)
    }
}
