//
//  NewGoalView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct NewGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    @StateObject private var viewModel: ViewModel
    
    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.gradientA
                    .ignoresSafeArea()
                Form {
                    Section("Goal Information") {
                        HStack {
                            Text("Title")
                            TextField(
                                "Title",
                                text: $viewModel.title,
                                prompt: Text("Enter the goal title here")
                            )
                            .accessibilityIdentifier("Title TextField")
                            .multilineTextAlignment(.trailing)
                            .tint(.blue)
                        }
                        HStack {
                            Text("Amount")
                            TextField(
                                "Amount",
                                value: $viewModel.tasksNeeded,
                                format: .number
                            )
                            .accessibilityIdentifier("Amount TextField")
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .tint(.blue)
                        }
                        Picker("Unit", selection: $viewModel.unit) {
                            ForEach(viewModel.units.list, id: \.self) {
                                Text($0)
                            }
                        }
                        .tint(.secondary)
                        .accessibilityIdentifier("Unit Picker")
                        Picker("Timeline", selection: $viewModel.timeline) {
                            ForEach(viewModel.timelines.list, id: \.self) {
                                Text($0)
                            }
                        }
                        .tint(.secondary)
                        .accessibilityIdentifier("Timeline Picker")
                    }

                    Section("Reminders") {
                        Toggle("Enable reminders", isOn: $viewModel.reminderEnabled.animation())
                            .accessibilityIdentifier("Reminders Toggle")
                            .tint(.green)
                        
                        if viewModel.reminderEnabled {
                            Picker("Frequency", selection: $viewModel.reminderFrequency) {
                                ForEach(viewModel.frequencies, id: \.self) {
                                    Text($0)
                                }
                            }
                            .tint(.secondary)
                            .accessibilityIdentifier("Frequency")
                            if viewModel.reminderFrequency == "Weekly" {
                                HStack {
                                    Spacer()
                                    ForEach(1...7, id: \.self) { day in
                                        Button {
                                            if viewModel.selectedDays.contains(day) {
                                                viewModel.selectedDays.remove(day)
                                            } else {
                                                viewModel.selectedDays.insert(day)
                                            }
                                        } label: {
                                            DayButtonRectangle(
                                                day: viewModel.dayAbbreviations[day - 1],
                                                daySelected: viewModel.selectedDays.contains(day) ? true : false
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    Spacer()
                                }
                                .accessibilityIdentifier("Day or days of Reminder")
                            } else if viewModel.reminderFrequency == "Monthly" {
                                VStack(alignment: .leading, spacing: Numbers.VStackSpacing) {
                                    Text("Days of Month")
                                    
                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible()),
                                        count: Numbers.numbersCount),
                                        spacing: Numbers.numbersSpacing
                                    ) {
                                        ForEach(1...31, id: \.self) { day in
                                            Button {
                                                if viewModel.selectedDaysOfMonth.contains(day) {
                                                    viewModel.selectedDaysOfMonth.remove(day)
                                                } else {
                                                    viewModel.selectedDaysOfMonth.insert(day)
                                                }
                                            } label: {
                                                Text(viewModel.dayOptions[day - 1])
                                                    .font(.caption)
                                                    .frame(width: Numbers.numbersFrame, height: Numbers.numbersFrame)
                                                    .background(
                                                        viewModel.selectedDaysOfMonth.contains(day)
                                                        ?
                                                        Color.blue : Color.gray.opacity(
                                                            Numbers.dayButtonForegroundOpacity
                                                        )
                                                    )
                                                    .foregroundColor(
                                                        viewModel.selectedDaysOfMonth.contains(day) ? .white : .primary
                                                    )
                                                    .cornerRadius(Numbers.dayButtonCornerRadius)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            DatePicker(
                                "Reminder time",
                                selection: $viewModel.reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                        }
                    }
                }
                .navigationTitle("New Goal")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .toolbarBackground(.hidden)
                .preferredColorScheme(.light)
                .toolbar {
                    Button("Save") {
                        viewModel.addGoal()
                        if viewModel.dismiss {
                            dismiss()
                        }
                    }
                    .tint(.blue)
                }
                
                .alert("Error", isPresented: $viewModel.showingNotificationsError) {
                    Button("Check Settings") {
                        guard let settingsURL = viewModel.createAppSettingsURL() else { return }
                        openURL(settingsURL)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(viewModel.notificationErrorMessage)
                        .multilineTextAlignment(.center)
                }
                .alert(
                    "Error",
                    isPresented: $viewModel.showTitleError
                ) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.titleErrorMessage)
                }
                .alert(
                    "Error",
                    isPresented: $viewModel.showEnterNumberError
                ) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.enterNumberErrorMessage)
                }
                .alert(
                    "Error",
                    isPresented: $viewModel.showWholeNumberError
                ) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.wholeNumberErrorMessage)
                }
                
                .onChange(of: viewModel.reminderEnabled, initial: false) { _, _  in
                    viewModel.checkSettings()
                }
                .onChange(of: viewModel.reminderTime, initial: false) { _, _  in
                    viewModel.checkSettings()
                }
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    NewGoalView(persistenceController: .preview)
        .environmentObject(persistenceController)
}
