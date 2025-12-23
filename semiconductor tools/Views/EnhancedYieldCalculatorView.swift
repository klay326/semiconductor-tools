//
//  EnhancedYieldCalculatorView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct EnhancedYieldCalculatorView: View {
    @StateObject private var dataStore = EnhancedYieldDataStore()
    @State private var showingNewRecord = false
    @State private var showingBinManager = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dataStore.records.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Yield Data")
                            .font(.headline)
                        Text("Create your first yield record to track wafer binning")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dataStore.records) { record in
                            NavigationLink(destination: YieldDetailView(record: record, dataStore: dataStore)) {
                                YieldRecordRow(record: record, dataStore: dataStore)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { dataStore.deleteRecord(at: $0) }
                        }
                    }
                }
            }
            .navigationTitle("Yield Binning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingBinManager = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingNewRecord = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewRecord) {
                NewYieldRecordView(dataStore: dataStore, isPresented: $showingNewRecord)
            }
            .sheet(isPresented: $showingBinManager) {
                BinManagerView(dataStore: dataStore, isPresented: $showingBinManager)
            }
        }
    }
}

struct YieldRecordRow: View {
    let record: YieldRecord
    let dataStore: EnhancedYieldDataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.waferName)
                        .fontWeight(.semibold)
                    Text("Lot: \(record.lotNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.1f", dataStore.getOverallYield(for: record)))%")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    Text("Yield")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bin distribution
            HStack(spacing: 4) {
                ForEach(dataStore.bins) { bin in
                    let percentage = dataStore.getBinPercentage(for: record, binId: bin.id)
                    if percentage > 0 {
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: bin.color))
                                .frame(height: 20)
                            Text("\(String(format: "%.0f", percentage))%")
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewYieldRecordView: View {
    @ObservedObject var dataStore: EnhancedYieldDataStore
    @Binding var isPresented: Bool
    
    @State private var waferName = ""
    @State private var lotNumber = ""
    @State private var binInputs: [UUID: String] = [:]
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Wafer Information")) {
                    TextField("Wafer Name", text: $waferName)
                    TextField("Lot Number", text: $lotNumber)
                }
                
                Section(header: Text("Die Counts by Bin")) {
                    ForEach(dataStore.bins) { bin in
                        HStack {
                            Text(bin.name)
                                .foregroundColor(Color(hex: bin.color))
                                .fontWeight(.semibold)
                            Spacer()
                            TextField("Count", text: Binding(
                                get: { binInputs[bin.id] ?? "" },
                                set: { binInputs[bin.id] = $0 }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        }
                    }
                }
            }
            .navigationTitle("New Yield Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecord()
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
        !waferName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lotNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !binInputs.values.allSatisfy({ $0.isEmpty })
    }
    
    private func saveRecord() {
        guard !waferName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a wafer name"
            showError = true
            return
        }
        
        guard !lotNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a lot number"
            showError = true
            return
        }
        
        var binCounts: [BinCount] = []
        for bin in dataStore.bins {
            if let countStr = binInputs[bin.id], let count = Int(countStr), count > 0 {
                binCounts.append(BinCount(binId: bin.id, count: count))
            }
        }
        
        guard !binCounts.isEmpty else {
            errorMessage = "Please enter at least one die count"
            showError = true
            return
        }
        
        let record = YieldRecord(waferName: waferName, lotNumber: lotNumber, binCounts: binCounts)
        dataStore.addRecord(record)
        isPresented = false
    }
}

struct YieldDetailView: View {
    var record: YieldRecord
    @ObservedObject var dataStore: EnhancedYieldDataStore
    @State private var isEditing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.waferName)
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lot Number")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(record.lotNumber)
                                .fontWeight(.semibold)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(record.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Overall Yield
                VStack(spacing: 12) {
                    Text("Overall Yield")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.2f", dataStore.getOverallYield(for: record)))%")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Bin Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bin Distribution")
                        .font(.headline)
                    
                    ForEach(dataStore.bins) { bin in
                        let count = dataStore.getBinCount(for: record, binId: bin.id)
                        let percentage = dataStore.getBinPercentage(for: record, binId: bin.id)
                        let dpm = dataStore.getDPM(for: record, binId: bin.id)
                        
                        VStack(spacing: 8) {
                            HStack {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color(hex: bin.color))
                                        .frame(width: 12, height: 12)
                                    Text(bin.name)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                Text("\(count) dies")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Percentage")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.2f", percentage))%")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("DPM")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.0f", dpm))")
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(8)
                            .background(Color(hex: bin.color).opacity(0.1))
                            .cornerRadius(6)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Summary Stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summary")
                        .font(.headline)
                    
                    HStack {
                        Text("Total Dies")
                        Spacer()
                        Text("\(dataStore.getTotalDies(for: record))")
                            .fontWeight(.semibold)
                    }
                    Divider()
                    
                    HStack {
                        Text("Wafer Created")
                        Spacer()
                        Text(record.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .fontWeight(.semibold)
                            .font(.caption)
                    }
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
    }
}

struct BinManagerView: View {
    @ObservedObject var dataStore: EnhancedYieldDataStore
    @Binding var isPresented: Bool
    @State private var newBinName = ""
    @State private var selectedColor = Color.blue
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Add new bin
                VStack(spacing: 12) {
                    Text("Add Custom Bin")
                        .font(.headline)
                    
                    TextField("Bin Name", text: $newBinName)
                        .textFieldStyle(.roundedBorder)
                    
                    ColorPicker("Bin Color", selection: $selectedColor)
                    
                    Button(action: addBin) {
                        Text("Add Bin")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newBinName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                // Current bins
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Bins")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(dataStore.bins) { bin in
                            HStack {
                                Circle()
                                    .fill(Color(hex: bin.color))
                                    .frame(width: 12, height: 12)
                                Text(bin.name)
                                Spacer()
                                Text("•••")
                                    .font(.caption)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { dataStore.deleteBin(dataStore.bins[$0]) }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Manage Bins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addBin() {
        let colorHex = String(format: "#%02x%02x%02x",
                              Int(selectedColor.components.red * 255),
                              Int(selectedColor.components.green * 255),
                              Int(selectedColor.components.blue * 255))
        dataStore.addCustomBin(name: newBinName, color: colorHex)
        newBinName = ""
        selectedColor = Color.blue
    }
}

extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Double(r), Double(g), Double(b))
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    EnhancedYieldCalculatorView()
}
