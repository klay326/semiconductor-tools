//
//  PeriodFrequencyModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct PeriodFrequencyCalculation: Identifiable, Codable {
    var id = UUID()
    var inputValue: Double
    var inputUnit: TimeUnit
    var frequencyValue: Double = 0
    var frequencyUnit: FrequencyUnit = .mhz
    var dateCreated: Date = Date()
    
    // Calculated properties
    var periodInSeconds: Double {
        inputValue * inputUnit.toSeconds
    }
    
    var frequencyInHz: Double {
        guard periodInSeconds > 0 else { return 0 }
        return 1.0 / periodInSeconds
    }
    
    var displayFrequency: Double {
        frequencyInHz / frequencyUnit.divisor
    }
    
    var displayFrequencyString: String {
        String(format: "%.6f", displayFrequency)
    }
    
    var isValid: Bool {
        inputValue > 0
    }
}

enum TimeUnit: String, CaseIterable, Codable {
    case nanoseconds = "ns"
    case microseconds = "μs"
    case milliseconds = "ms"
    case seconds = "s"
    
    var displayName: String {
        switch self {
        case .nanoseconds: return "Nanoseconds (ns)"
        case .microseconds: return "Microseconds (μs)"
        case .milliseconds: return "Milliseconds (ms)"
        case .seconds: return "Seconds (s)"
        }
    }
    
    var toSeconds: Double {
        switch self {
        case .nanoseconds: return 1e-9
        case .microseconds: return 1e-6
        case .milliseconds: return 1e-3
        case .seconds: return 1
        }
    }
}

enum FrequencyUnit: String, CaseIterable, Codable {
    case hz = "Hz"
    case khz = "kHz"
    case mhz = "MHz"
    case ghz = "GHz"
    
    var displayName: String {
        switch self {
        case .hz: return "Hz"
        case .khz: return "kHz"
        case .mhz: return "MHz"
        case .ghz: return "GHz"
        }
    }
    
    var divisor: Double {
        switch self {
        case .hz: return 1
        case .khz: return 1e3
        case .mhz: return 1e6
        case .ghz: return 1e9
        }
    }
}

// For storing multiple calculations
class PeriodFrequencyDataStore: NSObject, ObservableObject {
    @Published var calculations: [PeriodFrequencyCalculation] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaultsKey = "periodFrequencyCalculations"
    
    override init() {
        super.init()
        loadFromUserDefaults()
    }
    
    func addCalculation(_ calc: PeriodFrequencyCalculation) {
        calculations.append(calc)
    }
    
    func deleteCalculation(at index: Int) {
        calculations.remove(at: index)
    }
    
    func updateCalculation(_ calc: PeriodFrequencyCalculation) {
        if let index = calculations.firstIndex(where: { $0.id == calc.id }) {
            calculations[index] = calc
        }
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(calculations) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([PeriodFrequencyCalculation].self, from: data) {
            calculations = decoded
        }
    }
}
