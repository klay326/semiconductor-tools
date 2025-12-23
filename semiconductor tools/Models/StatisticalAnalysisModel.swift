//
//  StatisticalAnalysisModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct DataSet: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var values: [Double]
    let dateCreated: Date
    
    init(name: String, description: String = "", values: [Double] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.values = values
        self.dateCreated = Date()
    }
}

class StatisticalAnalysisDataStore: NSObject, ObservableObject {
    @Published var dataSets: [DataSet] = []
    
    private let dataSetsKey = "statisticalDataSets"
    
    override init() {
        super.init()
        loadData()
    }
    
    func addDataSet(_ dataSet: DataSet) {
        dataSets.append(dataSet)
        saveData()
    }
    
    func updateDataSet(_ dataSet: DataSet) {
        if let index = dataSets.firstIndex(where: { $0.id == dataSet.id }) {
            dataSets[index] = dataSet
            saveData()
        }
    }
    
    func deleteDataSet(at index: Int) {
        dataSets.remove(at: index)
        saveData()
    }
    
    // MARK: - Statistical Calculations
    
    func getMean(for dataSet: DataSet) -> Double {
        guard !dataSet.values.isEmpty else { return 0 }
        return dataSet.values.reduce(0, +) / Double(dataSet.values.count)
    }
    
    func getMedian(for dataSet: DataSet) -> Double {
        guard !dataSet.values.isEmpty else { return 0 }
        let sorted = dataSet.values.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return (sorted[count/2 - 1] + sorted[count/2]) / 2
        } else {
            return sorted[count/2]
        }
    }
    
    func getStdDev(for dataSet: DataSet) -> Double {
        guard dataSet.values.count > 1 else { return 0 }
        let mean = getMean(for: dataSet)
        let variance = dataSet.values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(dataSet.values.count - 1)
        return sqrt(variance)
    }
    
    func getMin(for dataSet: DataSet) -> Double {
        dataSet.values.min() ?? 0
    }
    
    func getMax(for dataSet: DataSet) -> Double {
        dataSet.values.max() ?? 0
    }
    
    func getRange(for dataSet: DataSet) -> Double {
        getMax(for: dataSet) - getMin(for: dataSet)
    }
    
    // Cpk = min((USL - mean) / (3 * stdDev), (mean - LSL) / (3 * stdDev))
    func getCpk(for dataSet: DataSet, lsl: Double, usl: Double) -> Double {
        guard dataSet.values.count > 1 else { return 0 }
        let mean = getMean(for: dataSet)
        let stdDev = getStdDev(for: dataSet)
        guard stdDev > 0 else { return 0 }
        
        let upperCpk = (usl - mean) / (3 * stdDev)
        let lowerCpk = (mean - lsl) / (3 * stdDev)
        
        return min(upperCpk, lowerCpk)
    }
    
    // Ppk = same as Cpk but with population std dev (divide by N instead of N-1)
    func getPpk(for dataSet: DataSet, lsl: Double, usl: Double) -> Double {
        guard !dataSet.values.isEmpty else { return 0 }
        let mean = getMean(for: dataSet)
        let variance = dataSet.values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(dataSet.values.count)
        let popStdDev = sqrt(variance)
        guard popStdDev > 0 else { return 0 }
        
        let upperPpk = (usl - mean) / (3 * popStdDev)
        let lowerPpk = (mean - lsl) / (3 * popStdDev)
        
        return min(upperPpk, lowerPpk)
    }
    
    func getVariance(for dataSet: DataSet) -> Double {
        guard dataSet.values.count > 1 else { return 0 }
        let mean = getMean(for: dataSet)
        return dataSet.values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(dataSet.values.count - 1)
    }
    
    func getCount(for dataSet: DataSet) -> Int {
        dataSet.values.count
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(dataSets) {
            UserDefaults.standard.set(encoded, forKey: dataSetsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: dataSetsKey),
           let decodedDataSets = try? JSONDecoder().decode([DataSet].self, from: data) {
            dataSets = decodedDataSets
        }
    }
}
