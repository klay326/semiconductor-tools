//
//  TestTimeCalculatorView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct TestTimeCalculatorView: View {
    @StateObject private var dataStore = TestTimeCalculatorDataStore()
    @State private var showingNewProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dataStore.testProfiles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Test Profiles")
                            .font(.headline)
                        Text("Create a test profile to estimate test time and throughput")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dataStore.testProfiles) { profile in
                            NavigationLink(destination: TestProfileDetailView(profile: profile, dataStore: dataStore)) {
                                TestProfileRowView(profile: profile, dataStore: dataStore)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { dataStore.deleteProfile(at: $0) }
                        }
                    }
                }
            }
            .navigationTitle("Test Time Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewProfile = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewProfile) {
                NewTestProfileView(dataStore: dataStore, isPresented: $showingNewProfile)
            }
        }
    }
}

struct TestProfileRowView: View {
    let profile: TestProfile
    let dataStore: TestTimeCalculatorDataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name)
                        .fontWeight(.semibold)
                    Text("\(profile.testSteps.count) steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Per Device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(dataStore.getTimePerDevice(for: profile)))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewTestProfileView: View {
    @ObservedObject var dataStore: TestTimeCalculatorDataStore
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var testSteps: [TestStep] = []
    @State private var stepName = ""
    @State private var stepDuration = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Name")) {
                    TextField("Profile Name", text: $name)
                }
                
                Section(header: Text("Add Test Steps")) {
                    HStack(spacing: 12) {
                        TextField("Step Name", text: $stepName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Duration (sec)", text: $stepDuration)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        
                        Button(action: addStep) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        .disabled(stepName.trimmingCharacters(in: .whitespaces).isEmpty || stepDuration.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                
                if !testSteps.isEmpty {
                    Section(header: Text("Test Steps (\(testSteps.count))")) {
                        ForEach(Array(testSteps.enumerated()), id: \.offset) { index, step in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(step.name)
                                        .fontWeight(.semibold)
                                    Text(formatTime(step.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: { removeStep(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Summary")) {
                        HStack {
                            Text("Total Time Per Device")
                            Spacer()
                            Text(formatTime(testSteps.reduce(0) { $0 + $1.duration }))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("New Test Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !testSteps.isEmpty
    }
    
    private func addStep() {
        guard let duration = Double(stepDuration) else {
            errorMessage = "Invalid duration format"
            showError = true
            return
        }
        
        let step = TestStep(name: stepName, duration: duration)
        testSteps.append(step)
        stepName = ""
        stepDuration = ""
    }
    
    private func removeStep(at index: Int) {
        testSteps.remove(at: index)
    }
    
    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a profile name"
            showError = true
            return
        }
        
        guard !testSteps.isEmpty else {
            errorMessage = "Please add at least one test step"
            showError = true
            return
        }
        
        let profile = TestProfile(name: name, testSteps: testSteps)
        dataStore.addProfile(profile)
        isPresented = false
    }
}

struct TestProfileDetailView: View {
    let profile: TestProfile
    @ObservedObject var dataStore: TestTimeCalculatorDataStore
    
    @State private var deviceCount = "100"
    @State private var parallelSlots = "1"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Created: \(profile.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Test Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test Steps")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(profile.testSteps.enumerated()), id: \.offset) { index, step in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(index + 1). \(step.name)")
                                        .fontWeight(.semibold)
                                    Text(formatTime(step.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Time Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Summary")
                        .font(.headline)
                    
                    let timePerDevice = dataStore.getTimePerDevice(for: profile)
                    
                    TimeStatRow(label: "Total Per Device", value: formatTime(timePerDevice))
                    TimeStatRow(label: "Total Per Device", value: String(format: "%.2f min", timePerDevice / 60))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Test Time Calculator
                VStack(alignment: .leading, spacing: 12) {
                    Text("Throughput Calculator")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Number of Devices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("Devices", text: $deviceCount)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Parallel Test Slots")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("Slots", text: $parallelSlots)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                    }
                    
                    if let devices = Int(deviceCount), let slots = Int(parallelSlots), devices > 0, slots > 0 {
                        let timePerDevice = dataStore.getTimePerDevice(for: profile)
                        let totalTime = dataStore.getTotalTestTimeForProfile(devices: devices, profile: profile)
                        let parallelTime = dataStore.getTimeWithParallel(totalTime: totalTime, parallelSlots: slots)
                        let throughput = dataStore.getThroughputWithParallel(devices: devices, totalTime: totalTime, parallelSlots: slots)
                        
                        VStack(spacing: 12) {
                            Divider()
                            
                            TimeStatRow(label: "Total Test Time", value: formatLongTime(parallelTime))
                            TimeStatRow(label: "Total Test Time (Hours)", value: String(format: "%.2f hrs", parallelTime / 3600))
                            TimeStatRow(label: "Throughput", value: String(format: "%.1f devices/hr", throughput))
                            
                            Text("Note: Assumes devices test in parallel on \(slots) slot(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimeStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

func formatTime(_ seconds: Double) -> String {
    if seconds < 60 {
        return String(format: "%.1f sec", seconds)
    } else if seconds < 3600 {
        return String(format: "%.1f min", seconds / 60)
    } else {
        return String(format: "%.2f hrs", seconds / 3600)
    }
}

func formatLongTime(_ seconds: Double) -> String {
    let hours = Int(seconds / 3600)
    let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
    let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    } else if minutes > 0 {
        return String(format: "%d:%02d min", minutes, secs)
    } else {
        return String(format: "%.1f sec", seconds)
    }
}

#Preview {
    TestTimeCalculatorView()
}
