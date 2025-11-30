//
//  CalendarView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/18/25.
//

import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: DateComponents?
    
    @Environment(\.colorScheme) var colorScheme

    var calendar: Calendar = .current

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = calendar
        calendarView.delegate = context.coordinator
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = dateSelection
        
        let tintColor = context.environment.colorScheme == .dark
            ? UIColor(.white)
            : UIColor(.black)
        calendarView.tintColor = tintColor
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate,
           let selectedDate = selectedDate {
            selection.setSelected(selectedDate, animated: true)
        }
        
        let tintColor = context.environment.colorScheme == .dark
            ? UIColor(.white)
            : UIColor(.black)
        uiView.tintColor = tintColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.selectedDate = dateComponents
        }
    }
}

#Preview {
    // Provide a concrete Binding for previews
    CalendarView(selectedDate: .constant(nil))
}
