//
//  ConditionalViews.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 2/12/26.
//

import Foundation
import SwiftUI

struct ConditionalSensoryFeedback<T: Equatable>: ViewModifier {
    let trigger: T
    let feedback: (T, T) -> FeedbackType
    
    enum FeedbackType {
        case decrease
        case increase
        case none
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.sensoryFeedback(trigger: trigger) { oldValue, newValue in
                switch feedback(oldValue, newValue) {
                case .decrease: return .decrease
                case .increase: return .increase
                case .none: return nil
                }
            }
        } else {
            content
        }
    }
}

extension View {
    func conditionalDecreaseFeedback<T: Equatable>(trigger: T, condition: @escaping (T, T) -> Bool) -> some View {
        modifier(ConditionalSensoryFeedback(trigger: trigger) { oldValue, newValue in
            condition(oldValue, newValue) ? .decrease : .none
        })
    }
    
    func conditionalIncreaseFeedback<T: Equatable>(trigger: T, condition: @escaping (T, T) -> Bool) -> some View {
        modifier(ConditionalSensoryFeedback(trigger: trigger) { oldValue, newValue in
            condition(oldValue, newValue) ? .increase : .none
        })
    }
}

struct HideTabBarIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.toolbar(.hidden, for: .tabBar)
        } else {
            content
                .onAppear { UITabBar.appearance().isHidden = true }
                .onDisappear { UITabBar.appearance().isHidden = false }
        }
    }
}
