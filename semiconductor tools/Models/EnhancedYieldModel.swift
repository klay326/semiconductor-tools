//
//  EnhancedYieldModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct BinDefinition: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: String // Store as hex
    
    init(id: UUID = UUID(), name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
}

struct BinCount: Identifiable, Codable {
    let id: UUID
    let binId: UUID
    var count: Int
    
    init(binId: UUID, count: Int = 0) {
        self.id = UUID()
        self.binId = binId
        self.count = count
    }
}

struct YieldRecord: Identifiable, Codable {
    let id: UUID
    var waferName: String
    var lotNumber: String
    var binCounts: [BinCount]
    let dateCreated: Date
    
    init(waferName: String, lotNumber: String, binCounts: [BinCount] = []) {
        self.id = UUID()
        self.waferName = waferName
        self.lotNumber = lotNumber
        self.binCounts = binCounts
        self.dateCreated = Date()
    }
}

class EnhancedYieldDataStore: NSObject, ObservableObject {
    @Published var bins: [BinDefinition] = []
    @Published var records: [YieldRecord] = []
    
    private let binsKey = "yieldBins"
    private let recordsKey = "yieldRecords"
    
    override init() {
        super.init()
        loadData()
        if bins.isEmpty {
            initializeDefaultBins()
        }
    }
    
    private func initializeDefaultBins() {
        bins = [
            BinDefinition(name: "Good", color: "#34C759"),      // Green
            BinDefinition(name: "Fail", color: "#FF3B30"),       // Red
            BinDefinition(name: "Marginal", color: "#FF9500"),   // Orange
        ]
        saveBins()
    }
    
    func addCustomBin(name: String, color: String) {
        let newBin = BinDefinition(name: name, color: color)
        bins.append(newBin)
        saveBins()
    }
    
    func updateBin(_ bin: BinDefinition) {
        if let index = bins.firstIndex(where: { $0.id == bin.id }) {
            bins[index] = bin
            saveBins()
        }
    }
    
    func deleteBin(_ bin: BinDefinition) {
        bins.removeAll { $0.id == bin.id }
        saveBins()
    }
    
    func addRecord(_ record: YieldRecord) {
        records.append(record)
        saveRecords()
    }
    
    func updateRecord(_ record: YieldRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    func deleteRecord(at index: Int) {
        records.remove(at: index)
        saveRecords()
    }
    
    // MARK: - Calculations
    
    func getTotalDies(for record: YieldRecord) -> Int {
        record.binCounts.reduce(0) { $0 + $1.count }
    }
    
    func getBinCount(for record: YieldRecord, binId: UUID) -> Int {
        record.binCounts.first(where: { $0.binId == binId })?.count ?? 0
    }
    
    func getBinPercentage(for record: YieldRecord, binId: UUID) -> Double {
        let total = getTotalDies(for: record)
        guard total > 0 else { return 0 }
        let binCount = getBinCount(for: record, binId: binId)
        return Double(binCount) / Double(total) * 100
    }
    
    func getOverallYield(for record: YieldRecord) -> Double {
        guard let goodBin = bins.first(where: { $0.name.lowercased() == "good" }) else {
            return 0
        }
        return getBinPercentage(for: record, binId: goodBin.id)
    }
    
    func getDPM(for record: YieldRecord, binId: UUID) -> Double {
        let percentage = getBinPercentage(for: record, binId: binId)
        return (percentage / 100.0) * 1_000_000
    }
    
    // MARK: - Persistence
    
    private func saveBins() {
        if let encoded = try? JSONEncoder().encode(bins) {
            UserDefaults.standard.set(encoded, forKey: binsKey)
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    private func loadData() {
        if let binsData = UserDefaults.standard.data(forKey: binsKey),
           let decodedBins = try? JSONDecoder().decode([BinDefinition].self, from: binsData) {
            bins = decodedBins
        }
        
        if let recordsData = UserDefaults.standard.data(forKey: recordsKey),
           let decodedRecords = try? JSONDecoder().decode([YieldRecord].self, from: recordsData) {
            records = decodedRecords
        }
    }
}
