//
//  EditGoalView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var goal: Goal
    
    init(goal: Goal, persistenceController: PersistenceController) {
        self.goal = goal
        let viewModel = ViewModel(persistenceController: persistenceController, goal: goal)
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
                                text: $viewModel.goalTitleInput,
                                prompt: Text("Enter the goal title here")
                            )
                            .multilineTextAlignment(.trailing)
                            .tint(.blue)
                        }
                        HStack {
                            Text("Amount")
                            TextField(
                                "Amount",
                                value: $viewModel.goalTasksInput,
                                format: .number
                            )
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .tint(.blue)
                        }
                        Picker("Unit", selection: $viewModel.goal.goalUnit) {
                            ForEach(viewModel.units.list, id: \.self) {
                                Text($0)
                            }
                        }
                        .tint(.secondary)
                        .accessibilityIdentifier("Unit Picker")
                        Picker("Timeline", selection: $viewModel.goal.goalTimeline) {
                            ForEach(viewModel.timelines.list, id: \.self) {
                                Text($0)
                            }
                        }
                        .accessibilityIdentifier("Timeline Picker")
                        .tint(.secondary)

                    }
                    
                    Section("Reminders") {
                        Toggle("Enable reminders", isOn: $goal.reminderEnabled.animation())
                            .tint(.green)
                        
                        if goal.reminderEnabled {
                            Picker("Frequency", selection: $viewModel.reminderFrequency) {
                                ForEach(viewModel.frequencies, id: \.self) {
                                    Text($0)
                                }
                            }
                            .tint(.secondary)
                            .accessibilityIdentifier("Frequency Picker")
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
                                selection: $viewModel.goal.goalReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .accessibilityIdentifier("Reminder Time Picker")
                        }
                    }
                }
                .navigationTitle("Edit Goal")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .toolbar {
                    Button("Save") {
                        viewModel.validateChanges(title: viewModel.goalTitleInput)
                        if viewModel.dismiss {
                            goal.objectWillChange.send()
                            viewModel.persistenceController.save()
                            dismiss()
                        }
                    }
                    .foregroundStyle(.blue)
                }
                .toolbarBackground(.hidden)
                .preferredColorScheme(.light)
                .alert("Oops!", isPresented: $viewModel.showingNotificationsError) {
                    Button("Check Settings") {
                        guard let settingsURL = UIApplication.notificationSettingsURL else { return }
                        openURL(settingsURL)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(viewModel.notificationErrorMessage)
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
                .alert(
                    "Warning",
                    isPresented: $viewModel.streakAlert
                ) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.streakAlertMessage)
                }
                
                .onChange(of: goal.reminderEnabled, initial: false) { _, _  in
                    viewModel.updateReminder(goal)
                }
                .onChange(of: viewModel.goal.goalTimeline) { _, _ in
                    if goal.streak > 0 {
                        viewModel.streakAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    EditGoalView(goal: Goal.example(controller: persistenceController), persistenceController: persistenceController)
        .environmentObject(persistenceController)
}
