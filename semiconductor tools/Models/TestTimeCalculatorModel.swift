//
//  TestTimeCalculatorModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct TestStep: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: Double // in seconds
    
    init(name: String, duration: Double = 0) {
        self.id = UUID()
        self.name = name
        self.duration = duration
    }
}

struct TestProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var testSteps: [TestStep]
    let dateCreated: Date
    
    init(name: String, testSteps: [TestStep] = []) {
        self.id = UUID()
        self.name = name
        self.testSteps = testSteps
        self.dateCreated = Date()
    }
}

class TestTimeCalculatorDataStore: NSObject, ObservableObject {
    @Published var testProfiles: [TestProfile] = []
    
    private let profilesKey = "testTimeProfiles"
    
    override init() {
        super.init()
        loadData()
    }
    
    func addProfile(_ profile: TestProfile) {
        testProfiles.append(profile)
        saveData()
    }
    
    func updateProfile(_ profile: TestProfile) {
        if let index = testProfiles.firstIndex(where: { $0.id == profile.id }) {
            testProfiles[index] = profile
            saveData()
        }
    }
    
    func deleteProfile(at index: Int) {
        testProfiles.remove(at: index)
        saveData()
    }
    
    // MARK: - Calculations
    
    func getTotalStepTime(for profile: TestProfile) -> Double {
        profile.testSteps.reduce(0) { $0 + $1.duration }
    }
    
    func getTimePerDevice(for profile: TestProfile) -> Double {
        getTotalStepTime(for: profile)
    }
    
    func getTotalTestTime(devices: Int, timePerDevice: Double) -> Double {
        Double(devices) * timePerDevice
    }
    
    func getTotalTestTimeForProfile(devices: Int, profile: TestProfile) -> Double {
        getTotalTestTime(devices: devices, timePerDevice: getTimePerDevice(for: profile))
    }
    
    func getThroughput(devices: Int, totalTime: Double) -> Double {
        guard totalTime > 0 else { return 0 }
        return Double(devices) / (totalTime / 3600.0) // devices per hour
    }
    
    func getTimeWithParallel(totalTime: Double, parallelSlots: Int) -> Double {
        guard parallelSlots > 0 else { return totalTime }
        return totalTime / Double(parallelSlots)
    }
    
    func getThroughputWithParallel(devices: Int, totalTime: Double, parallelSlots: Int) -> Double {
        let timeWithParallel = getTimeWithParallel(totalTime: totalTime, parallelSlots: parallelSlots)
        return getThroughput(devices: devices, totalTime: timeWithParallel)
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(testProfiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decodedProfiles = try? JSONDecoder().decode([TestProfile].self, from: data) {
            testProfiles = decodedProfiles
        }
    }
}
