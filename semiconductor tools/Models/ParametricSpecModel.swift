//
//  ParametricSpecModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct ParametricSpec: Identifiable, Codable {
    let id: UUID
    var name: String
    var testName: String
    var minLimit: Double
    var maxLimit: Double
    var unit: String
    var description: String
    let dateCreated: Date
    
    init(name: String, testName: String, minLimit: Double, maxLimit: Double, unit: String, description: String = "") {
        self.id = UUID()
        self.name = name
        self.testName = testName
        self.minLimit = minLimit
        self.maxLimit = maxLimit
        self.unit = unit
        self.description = description
        self.dateCreated = Date()
    }
}

struct MeasuredValue: Identifiable, Codable {
    let id: UUID
    var specId: UUID
    var value: Double
    var measuredDate: Date
    
    init(specId: UUID, value: Double) {
        self.id = UUID()
        self.specId = specId
        self.value = value
        self.measuredDate = Date()
    }
}

class ParametricSpecDataStore: NSObject, ObservableObject {
    @Published var specs: [ParametricSpec] = []
    @Published var measurements: [MeasuredValue] = []
    
    private let specsKey = "parametricSpecs"
    private let measurementsKey = "parametricMeasurements"
    
    override init() {
        super.init()
        loadData()
    }
    
    func addSpec(_ spec: ParametricSpec) {
        specs.append(spec)
        saveSpecs()
    }
    
    func updateSpec(_ spec: ParametricSpec) {
        if let index = specs.firstIndex(where: { $0.id == spec.id }) {
            specs[index] = spec
            saveSpecs()
        }
    }
    
    func deleteSpec(at index: Int) {
        specs.remove(at: index)
        saveSpecs()
    }
    
    func addMeasurement(_ measurement: MeasuredValue) {
        measurements.append(measurement)
        saveMeasurements()
    }
    
    func getMeasurements(for specId: UUID) -> [MeasuredValue] {
        measurements.filter { $0.specId == specId }.sorted { $0.measuredDate > $1.measuredDate }
    }
    
    // MARK: - Calculations
    
    enum TestStatus {
        case pass
        case fail
        case marginal
        case noData
    }
    
    func getTestStatus(for spec: ParametricSpec, value: Double) -> TestStatus {
        if value >= spec.minLimit && value <= spec.maxLimit {
            return .pass
        } else {
            return .fail
        }
    }
    
    func getTestStatus(for spec: ParametricSpec) -> TestStatus {
        let specMeasurements = getMeasurements(for: spec.id)
        guard let latestMeasurement = specMeasurements.first else {
            return .noData
        }
        return getTestStatus(for: spec, value: latestMeasurement.value)
    }
    
    func getLatestMeasurement(for specId: UUID) -> MeasuredValue? {
        getMeasurements(for: specId).first
    }
    
    func isValueInSpec(specId: UUID, value: Double) -> Bool {
        guard let spec = specs.first(where: { $0.id == specId }) else { return false }
        return value >= spec.minLimit && value <= spec.maxLimit
    }
    
    func getMargin(for spec: ParametricSpec, value: Double) -> Double {
        let midpoint = (spec.minLimit + spec.maxLimit) / 2.0
        let range = (spec.maxLimit - spec.minLimit) / 2.0
        let deviation = abs(value - midpoint)
        guard range > 0 else { return 0 }
        return ((range - deviation) / range) * 100.0
    }
    
    // MARK: - Persistence
    
    private func saveSpecs() {
        if let encoded = try? JSONEncoder().encode(specs) {
            UserDefaults.standard.set(encoded, forKey: specsKey)
        }
    }
    
    private func saveMeasurements() {
        if let encoded = try? JSONEncoder().encode(measurements) {
            UserDefaults.standard.set(encoded, forKey: measurementsKey)
        }
    }
    
    private func loadData() {
        if let specsData = UserDefaults.standard.data(forKey: specsKey),
           let decodedSpecs = try? JSONDecoder().decode([ParametricSpec].self, from: specsData) {
            specs = decodedSpecs
        }
        
        if let measurementsData = UserDefaults.standard.data(forKey: measurementsKey),
           let decodedMeasurements = try? JSONDecoder().decode([MeasuredValue].self, from: measurementsData) {
            measurements = decodedMeasurements
        }
    }
}
