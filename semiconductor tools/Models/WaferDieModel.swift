//
//  WaferDieModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct WaferDieCalculation: Identifiable, Codable {
    var id = UUID()
    var waferName: String
    var lotNumber: String
    var totalDies: Int
    var goodDies: Int
    var defectiveDies: Int
    var dateCreated: Date = Date()
    
    // Calculated properties
    var yieldPercentage: Double {
        guard totalDies > 0 else { return 0 }
        return (Double(goodDies) / Double(totalDies)) * 100
    }
    
    var defectRate: Double {
        guard totalDies > 0 else { return 0 }
        return (Double(defectiveDies) / Double(totalDies)) * 100
    }
    
    var dpmValue: Double {
        // Defects Per Million
        guard totalDies > 0 else { return 0 }
        return (Double(defectiveDies) / Double(totalDies)) * 1_000_000
    }
    
    // Validate data
    var isValid: Bool {
        totalDies > 0 && goodDies >= 0 && defectiveDies >= 0 &&
        (goodDies + defectiveDies) <= totalDies
    }
}

// For storing multiple calculations
class WaferDieDataStore: ObservableObject {
    @Published var calculations: [WaferDieCalculation] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaultsKey = "waferDieCalculations"
    
    init() {
        loadFromUserDefaults()
    }
    
    func addCalculation(_ calc: WaferDieCalculation) {
        calculations.append(calc)
    }
    
    func deleteCalculation(at index: Int) {
        calculations.remove(at: index)
    }
    
    func updateCalculation(_ calc: WaferDieCalculation) {
        if let index = calculations.firstIndex(where: { $0.id == calc.id }) {
            calculations[index] = calc
        }
    }
    
    func averageYield() -> Double {
        guard !calculations.isEmpty else { return 0 }
        let sum = calculations.reduce(0) { $0 + $1.yieldPercentage }
        return sum / Double(calculations.count)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(calculations) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([WaferDieCalculation].self, from: data) {
            calculations = decoded
        }
    }
}
