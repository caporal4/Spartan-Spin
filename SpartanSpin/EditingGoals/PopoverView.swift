//
//  TimelinePopover.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/1/26.
//

import SwiftUI

struct PopoverView: View {
    @State private var showTimelineInfo = false
    let popoverText: String
    let frameWidth: CGFloat
    
    var body: some View {
        Button {
            showTimelineInfo = true
        } label: {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showTimelineInfo) {
            VStack {
                Text(popoverText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: frameWidth)
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    PopoverView(popoverText: "Enter the number of tasks you want to complete for this goal.", frameWidth: 200)
}
