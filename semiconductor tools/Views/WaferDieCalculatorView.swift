//
//  WaferDieCalculatorView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct WaferDieCalculatorView: View {
    @StateObject private var dataStore = WaferDieDataStore()
    @State private var showingNewCalculation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if dataStore.calculations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "circle.grid.3x3")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Wafer/Die Data")
                            .font(.headline)
                        Text("Create your first calculation to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("Summary")) {
                            HStack {
                                Text("Average Yield")
                                Spacer()
                                Text(String(format: "%.2f%%", dataStore.averageYield()))
                                    .fontWeight(.semibold)
                            }
                            HStack {
                                Text("Total Calculations")
                                Spacer()
                                Text("\(dataStore.calculations.count)")
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Section(header: Text("Calculations")) {
                            ForEach(dataStore.calculations) { calc in
                                NavigationLink(destination: WaferDieDetailView(calculation: calc, dataStore: dataStore)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(calc.waferName)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text(String(format: "%.2f%%", calc.yieldPercentage))
                                                .foregroundColor(.green)
                                                .fontWeight(.semibold)
                                        }
                                        HStack {
                                            Text("Lot: \(calc.lotNumber)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("Dies: \(calc.goodDies)/\(calc.totalDies)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { dataStore.deleteCalculation(at: $0) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wafer/Die Calculator")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewCalculation = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewCalculation) {
                NewWaferDieCalculationView(dataStore: dataStore, isPresented: $showingNewCalculation)
            }
        }
    }
}

struct NewWaferDieCalculationView: View {
    @ObservedObject var dataStore: WaferDieDataStore
    @Binding var isPresented: Bool
    
    @State private var waferName = ""
    @State private var lotNumber = ""
    @State private var totalDies = ""
    @State private var goodDies = ""
    @State private var defectiveDies = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Wafer Information")) {
                    TextField("Wafer Name", text: $waferName)
                        .textContentType(.none)
                    TextField("Lot Number", text: $lotNumber)
                        .textContentType(.none)
                }
                
                Section(header: Text("Die Count")) {
                    TextField("Total Dies", text: $totalDies)
                        .keyboardType(.numberPad)
                    TextField("Good Dies", text: $goodDies)
                        .keyboardType(.numberPad)
                    TextField("Defective Dies", text: $defectiveDies)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Auto-Calculate")) {
                    if !totalDies.isEmpty && !goodDies.isEmpty {
                        Button(action: autoCalculateDefective) {
                            Text("Calculate Defective Dies")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("New Calculation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveCalculation()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canSave: Bool {
        !waferName.isEmpty && !lotNumber.isEmpty && !totalDies.isEmpty &&
        (!goodDies.isEmpty || !defectiveDies.isEmpty)
    }
    
    private func autoCalculateDefective() {
        if let total = Int(totalDies), let good = Int(goodDies) {
            defectiveDies = String(max(0, total - good))
        }
    }
    
    private func saveCalculation() {
        guard let total = Int(totalDies), total > 0 else {
            errorMessage = "Total dies must be greater than 0"
            showError = true
            return
        }
        
        let good = Int(goodDies) ?? 0
        let defective = Int(defectiveDies) ?? 0
        
        // Auto-calculate if one is missing
        let finalGood = goodDies.isEmpty ? (total - defective) : good
        let finalDefective = defectiveDies.isEmpty ? (total - good) : defective
        
        guard finalGood >= 0 && finalDefective >= 0 else {
            errorMessage = "Good and defective dies cannot be negative"
            showError = true
            return
        }
        
        guard (finalGood + finalDefective) <= total else {
            errorMessage = "Good dies + Defective dies cannot exceed total dies"
            showError = true
            return
        }
        
        let calculation = WaferDieCalculation(
            waferName: waferName,
            lotNumber: lotNumber,
            totalDies: total,
            goodDies: finalGood,
            defectiveDies: finalDefective
        )
        
        dataStore.addCalculation(calculation)
        isPresented = false
    }
}

struct WaferDieDetailView: View {
    let calculation: WaferDieCalculation
    @ObservedObject var dataStore: WaferDieDataStore
    @State private var isEditing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(calculation.waferName)
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack {
                        Text("Lot: \(calculation.lotNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(calculation.dateCreated.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Key Metrics
                VStack(spacing: 12) {
                    MetricCard(
                        title: "Yield",
                        value: String(format: "%.2f%%", calculation.yieldPercentage),
                        color: .green
                    )
                    MetricCard(
                        title: "Defect Rate",
                        value: String(format: "%.2f%%", calculation.defectRate),
                        color: .orange
                    )
                    MetricCard(
                        title: "DPM (Defects Per Million)",
                        value: String(format: "%.0f", calculation.dpmValue),
                        color: .blue
                    )
                }
                
                // Die Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Die Summary")
                        .font(.headline)
                    
                    DetailRow(label: "Total Dies", value: "\(calculation.totalDies)")
                    DetailRow(label: "Good Dies", value: "\(calculation.goodDies)", color: .green)
                    DetailRow(label: "Defective Dies", value: "\(calculation.defectiveDies)", color: .red)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditWaferDieCalculationView(calculation: calculation, dataStore: dataStore, isPresented: $isEditing)
        }
    }
}

struct EditWaferDieCalculationView: View {
    let calculation: WaferDieCalculation
    @ObservedObject var dataStore: WaferDieDataStore
    @Binding var isPresented: Bool
    
    @State private var waferName: String
    @State private var lotNumber: String
    @State private var totalDies: String
    @State private var goodDies: String
    @State private var defectiveDies: String
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(calculation: WaferDieCalculation, dataStore: WaferDieDataStore, isPresented: Binding<Bool>) {
        self.calculation = calculation
        self.dataStore = dataStore
        self._isPresented = isPresented
        
        _waferName = State(initialValue: calculation.waferName)
        _lotNumber = State(initialValue: calculation.lotNumber)
        _totalDies = State(initialValue: "\(calculation.totalDies)")
        _goodDies = State(initialValue: "\(calculation.goodDies)")
        _defectiveDies = State(initialValue: "\(calculation.defectiveDies)")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Wafer Information")) {
                    TextField("Wafer Name", text: $waferName)
                    TextField("Lot Number", text: $lotNumber)
                }
                
                Section(header: Text("Die Count")) {
                    TextField("Total Dies", text: $totalDies)
                        .keyboardType(.numberPad)
                    TextField("Good Dies", text: $goodDies)
                        .keyboardType(.numberPad)
                    TextField("Defective Dies", text: $defectiveDies)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Calculation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveChanges() {
        guard let total = Int(totalDies), total > 0 else {
            errorMessage = "Total dies must be greater than 0"
            showError = true
            return
        }
        
        let good = Int(goodDies) ?? 0
        let defective = Int(defectiveDies) ?? 0
        
        guard good >= 0 && defective >= 0 else {
            errorMessage = "Dies cannot be negative"
            showError = true
            return
        }
        
        guard (good + defective) <= total else {
            errorMessage = "Good dies + Defective dies cannot exceed total dies"
            showError = true
            return
        }
        
        var updated = calculation
        updated.waferName = waferName
        updated.lotNumber = lotNumber
        updated.totalDies = total
        updated.goodDies = good
        updated.defectiveDies = defective
        
        dataStore.updateCalculation(updated)
        isPresented = false
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(color)
                .opacity(0.3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    NavigationStack {
        WaferDieCalculatorView()
    }
}
