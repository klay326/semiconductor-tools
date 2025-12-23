//
//  StatisticalAnalysisView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct StatisticalAnalysisView: View {
    @StateObject private var dataStore = StatisticalAnalysisDataStore()
    @State private var showingNewDataSet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dataStore.dataSets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Data Sets")
                            .font(.headline)
                        Text("Create a data set to perform statistical analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dataStore.dataSets) { dataSet in
                            NavigationLink(destination: DataSetDetailView(dataSet: dataSet, dataStore: dataStore)) {
                                DataSetRowView(dataSet: dataSet, dataStore: dataStore)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { dataStore.deleteDataSet(at: $0) }
                        }
                    }
                }
            }
            .navigationTitle("Statistical Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewDataSet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewDataSet) {
                NewDataSetView(dataStore: dataStore, isPresented: $showingNewDataSet)
            }
        }
    }
}

struct DataSetRowView: View {
    let dataSet: DataSet
    let dataStore: StatisticalAnalysisDataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dataSet.name)
                        .fontWeight(.semibold)
                    Text("\(dataStore.getCount(for: dataSet)) values")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Mean")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.3g", dataStore.getMean(for: dataSet)))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewDataSetView: View {
    @ObservedObject var dataStore: StatisticalAnalysisDataStore
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var description = ""
    @State private var valueInput = ""
    @State private var values: [Double] = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Data Set Info")) {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
                }
                
                Section(header: Text("Add Values")) {
                    HStack(spacing: 12) {
                        TextField("Enter value", text: $valueInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: addValue) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        .disabled(valueInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                
                if !values.isEmpty {
                    Section(header: Text("Values (\(values.count))")) {
                        ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                            HStack {
                                Text(String(format: "%.6g", value))
                                    .fontWeight(.semibold)
                                Spacer()
                                Button(action: { removeValue(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Data Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveDataSet()
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
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !values.isEmpty
    }
    
    private func addValue() {
        guard let value = Double(valueInput) else {
            errorMessage = "Invalid number format"
            showError = true
            return
        }
        values.append(value)
        valueInput = ""
    }
    
    private func removeValue(at index: Int) {
        values.remove(at: index)
    }
    
    private func saveDataSet() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a data set name"
            showError = true
            return
        }
        
        guard !values.isEmpty else {
            errorMessage = "Please add at least one value"
            showError = true
            return
        }
        
        let dataSet = DataSet(name: name, description: description, values: values)
        dataStore.addDataSet(dataSet)
        isPresented = false
    }
}

struct DataSetDetailView: View {
    var dataSet: DataSet
    @ObservedObject var dataStore: StatisticalAnalysisDataStore
    @State private var lslInput = ""
    @State private var uslInput = ""
    @State private var showCpkCalculation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(dataSet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if !dataSet.description.isEmpty {
                        Text(dataSet.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Basic Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Basic Statistics")
                        .font(.headline)
                    
                    StatRow(label: "Count", value: "\(dataStore.getCount(for: dataSet))")
                    StatRow(label: "Mean", value: String(format: "%.6g", dataStore.getMean(for: dataSet)))
                    StatRow(label: "Median", value: String(format: "%.6g", dataStore.getMedian(for: dataSet)))
                    StatRow(label: "Std Dev", value: String(format: "%.6g", dataStore.getStdDev(for: dataSet)))
                    StatRow(label: "Variance", value: String(format: "%.6g", dataStore.getVariance(for: dataSet)))
                    StatRow(label: "Min", value: String(format: "%.6g", dataStore.getMin(for: dataSet)))
                    StatRow(label: "Max", value: String(format: "%.6g", dataStore.getMax(for: dataSet)))
                    StatRow(label: "Range", value: String(format: "%.6g", dataStore.getRange(for: dataSet)))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Cpk/Ppk Calculation
                VStack(alignment: .leading, spacing: 12) {
                    Text("Process Capability (Cpk/Ppk)")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Lower Spec Limit (LSL)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("LSL", text: $lslInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Upper Spec Limit (USL)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("USL", text: $uslInput)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                    }
                    
                    if let lsl = Double(lslInput), let usl = Double(uslInput), lsl < usl {
                        VStack(spacing: 12) {
                            Divider()
                            
                            HStack {
                                Text("Cpk")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(String(format: "%.4f", dataStore.getCpk(for: dataSet, lsl: lsl, usl: usl)))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(cpkColor(dataStore.getCpk(for: dataSet, lsl: lsl, usl: usl)))
                            }
                            
                            HStack {
                                Text("Ppk")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(String(format: "%.4f", dataStore.getPpk(for: dataSet, lsl: lsl, usl: usl)))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(cpkColor(dataStore.getPpk(for: dataSet, lsl: lsl, usl: usl)))
                            }
                            
                            Text("Note: Cpk ≥ 1.33 is generally considered capable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // All Values
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Values")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(dataSet.values.enumerated()), id: \.offset) { index, value in
                            HStack {
                                Text("[\(index + 1)]")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.6g", value))
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func cpkColor(_ cpk: Double) -> Color {
        if cpk >= 1.33 {
            return .green
        } else if cpk >= 1.0 {
            return .orange
        } else {
            return .red
        }
    }
}

struct StatRow: View {
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

#Preview {
    StatisticalAnalysisView()
}
