//
//  ParametricSpecCalculatorView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct ParametricSpecCalculatorView: View {
    @StateObject private var dataStore = ParametricSpecDataStore()
    @State private var showingNewSpec = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dataStore.specs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Test Specs")
                            .font(.headline)
                        Text("Create test specifications to track parametric values")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dataStore.specs) { spec in
                            NavigationLink(destination: SpecDetailView(spec: spec, dataStore: dataStore)) {
                                SpecRowView(spec: spec, dataStore: dataStore)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { dataStore.deleteSpec(at: $0) }
                        }
                    }
                }
            }
            .navigationTitle("Parametric Specs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewSpec = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewSpec) {
                NewSpecView(dataStore: dataStore, isPresented: $showingNewSpec)
            }
        }
    }
}

struct SpecRowView: View {
    let spec: ParametricSpec
    let dataStore: ParametricSpecDataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(spec.name)
                        .fontWeight(.semibold)
                    Text(spec.testName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(status: dataStore.getTestStatus(for: spec))
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Limits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.3g", spec.minLimit)) - \(String(format: "%.3g", spec.maxLimit)) \(spec.unit)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                
                if let measurement = dataStore.getLatestMeasurement(for: spec.id) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Last Measured")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.3g", measurement.value)) \(spec.unit)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: ParametricSpecDataStore.TestStatus
    
    var body: some View {
        switch status {
        case .pass:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
        case .fail:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
        case .marginal:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 16))
        case .noData:
            Image(systemName: "circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
    }
}

struct NewSpecView: View {
    @ObservedObject var dataStore: ParametricSpecDataStore
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var testName = ""
    @State private var minLimit = ""
    @State private var maxLimit = ""
    @State private var unit = "V"
    @State private var description = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Specification Info")) {
                    TextField("Spec Name", text: $name)
                    TextField("Test Name", text: $testName)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Limits")) {
                    TextField("Minimum Limit", text: $minLimit)
                        .keyboardType(.decimalPad)
                    TextField("Maximum Limit", text: $maxLimit)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Unit")) {
                    Picker("Unit", selection: $unit) {
                        Text("Voltage").tag("V")
                        Text("mV").tag("mV")
                        Text("Current (A)").tag("A")
                        Text("mA").tag("mA")
                        Text("μA").tag("μA")
                        Text("Resistance (Ω)").tag("Ω")
                        Text("kΩ").tag("kΩ")
                        Text("Frequency (Hz)").tag("Hz")
                        Text("MHz").tag("MHz")
                        Text("GHz").tag("GHz")
                        Text("Time (ns)").tag("ns")
                        Text("μs").tag("μs")
                    }
                }
            }
            .navigationTitle("New Specification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSpec()
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
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !testName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(minLimit) != nil &&
        Double(maxLimit) != nil &&
        !unit.isEmpty
    }
    
    private func saveSpec() {
        guard let minVal = Double(minLimit) else {
            errorMessage = "Invalid minimum limit"
            showError = true
            return
        }
        
        guard let maxVal = Double(maxLimit) else {
            errorMessage = "Invalid maximum limit"
            showError = true
            return
        }
        
        guard minVal < maxVal else {
            errorMessage = "Minimum must be less than maximum"
            showError = true
            return
        }
        
        let spec = ParametricSpec(
            name: name,
            testName: testName,
            minLimit: minVal,
            maxLimit: maxVal,
            unit: unit,
            description: description
        )
        dataStore.addSpec(spec)
        isPresented = false
    }
}

struct SpecDetailView: View {
    let spec: ParametricSpec
    @ObservedObject var dataStore: ParametricSpecDataStore
    @State private var measurementValue = ""
    @State private var showingEdit = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(spec.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(spec.testName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Specification Limits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Specification Limits")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minimum")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.6g", spec.minLimit)) \(spec.unit)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Maximum")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.6g", spec.maxLimit)) \(spec.unit)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Latest Measurement
                if let measurement = dataStore.getLatestMeasurement(for: spec.id) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Latest Measurement")
                            .font(.headline)
                        
                        let status = dataStore.getTestStatus(for: spec, value: measurement.value)
                        let margin = dataStore.getMargin(for: spec, value: measurement.value)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Value")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.6g", measurement.value)) \(spec.unit)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(statusColor(status))
                            }
                            Spacer()
                            StatusBadge(status: status)
                                .font(.system(size: 24))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Test Margin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", margin))%")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Measured")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(measurement.measuredDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Add Measurement
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Measurement")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        TextField("Value", text: $measurementValue)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Text(spec.unit)
                            .foregroundColor(.secondary)
                        
                        Button(action: addMeasurement) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        .disabled(measurementValue.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Measurement History
                if !dataStore.getMeasurements(for: spec.id).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Measurement History")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(dataStore.getMeasurements(for: spec.id).prefix(5)) { measurement in
                                HStack {
                                    Text("\(String(format: "%.6g", measurement.value)) \(spec.unit)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(measurement.measuredDate.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                if !spec.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(spec.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addMeasurement() {
        guard let value = Double(measurementValue) else {
            errorMessage = "Invalid measurement value"
            showError = true
            return
        }
        
        let measurement = MeasuredValue(specId: spec.id, value: value)
        dataStore.addMeasurement(measurement)
        measurementValue = ""
    }
    
    private func statusColor(_ status: ParametricSpecDataStore.TestStatus) -> Color {
        switch status {
        case .pass: return .green
        case .fail: return .red
        case .marginal: return .orange
        case .noData: return .gray
        }
    }
}

#Preview {
    ParametricSpecCalculatorView()
}
