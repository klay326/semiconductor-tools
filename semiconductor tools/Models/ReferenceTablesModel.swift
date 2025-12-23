//
//  ReferenceTablesModel.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import Foundation
import Combine

struct ReferenceTable: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let items: [ReferenceItem]
}

struct ReferenceItem: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let unit: String
    let description: String?
}

class ReferenceTablesDataStore: NSObject, ObservableObject {
    @Published var tables: [ReferenceTable] = []
    
    override init() {
        super.init()
        loadTables()
    }
    
    private func loadTables() {
        tables = [
            // Common Voltage Thresholds
            ReferenceTable(
                title: "Common Voltage Thresholds",
                category: "Voltage",
                items: [
                    ReferenceItem(name: "Logic High (5V CMOS)", value: "3.5", unit: "V", description: "Minimum high voltage for 5V logic"),
                    ReferenceItem(name: "Logic Low (5V CMOS)", value: "0.5", unit: "V", description: "Maximum low voltage for 5V logic"),
                    ReferenceItem(name: "Logic High (3.3V CMOS)", value: "2.0", unit: "V", description: "Minimum high voltage for 3.3V logic"),
                    ReferenceItem(name: "Logic Low (3.3V CMOS)", value: "0.8", unit: "V", description: "Maximum low voltage for 3.3V logic"),
                    ReferenceItem(name: "Logic High (1.8V CMOS)", value: "1.26", unit: "V", description: "Minimum high voltage for 1.8V logic"),
                    ReferenceItem(name: "Logic Low (1.8V CMOS)", value: "0.54", unit: "V", description: "Maximum low voltage for 1.8V logic"),
                ]
            ),
            
            // Common Current Limits
            ReferenceTable(
                title: "Common Current Limits",
                category: "Current",
                items: [
                    ReferenceItem(name: "Leakage Current (max)", value: "1", unit: "μA", description: "Typical max static leakage"),
                    ReferenceItem(name: "Supply Current (typical)", value: "10", unit: "mA", description: "Typical supply current during operation"),
                    ReferenceItem(name: "Output Drive Current", value: "20", unit: "mA", description: "Typical output drive capability"),
                    ReferenceItem(name: "ESD Threshold", value: "2", unit: "kV", description: "Electrostatic discharge protection level"),
                ]
            ),
            
            // Common Frequency Standards
            ReferenceTable(
                title: "Common Frequency Standards",
                category: "Frequency",
                items: [
                    ReferenceItem(name: "Crystal Oscillator", value: "32.768", unit: "kHz", description: "Common real-time clock frequency"),
                    ReferenceItem(name: "Audio Sample Rate", value: "44.1", unit: "kHz", description: "CD quality audio"),
                    ReferenceItem(name: "USB 2.0", value: "480", unit: "Mbps", description: "High-speed USB standard"),
                    ReferenceItem(name: "DDR3 Memory", value: "1.6", unit: "GHz", description: "Typical DDR3 clock speed"),
                    ReferenceItem(name: "DDR4 Memory", value: "2.4", unit: "GHz", description: "Typical DDR4 clock speed"),
                    ReferenceItem(name: "PCIe 3.0", value: "8", unit: "GT/s", description: "PCIe Gen 3 speed per lane"),
                ]
            ),
            
            // Temperature Ranges
            ReferenceTable(
                title: "Standard Temperature Ranges",
                category: "Temperature",
                items: [
                    ReferenceItem(name: "Commercial Grade", value: "0 to 70", unit: "°C", description: "Standard industrial devices"),
                    ReferenceItem(name: "Industrial Grade", value: "-40 to 85", unit: "°C", description: "Extended temperature range"),
                    ReferenceItem(name: "Automotive Grade", value: "-40 to 125", unit: "°C", description: "High temperature automotive devices"),
                    ReferenceItem(name: "Military Grade", value: "-55 to 125", unit: "°C", description: "Extreme temperature range"),
                ]
            ),
            
            // Power Consumption Classes
            ReferenceTable(
                title: "Power Consumption Classes",
                category: "Power",
                items: [
                    ReferenceItem(name: "Ultra Low Power", value: "< 1", unit: "mW", description: "Battery-powered IoT devices"),
                    ReferenceItem(name: "Low Power", value: "1 - 10", unit: "mW", description: "Wearables and sensors"),
                    ReferenceItem(name: "Medium Power", value: "10 - 100", unit: "mW", description: "Mobile and portable devices"),
                    ReferenceItem(name: "High Power", value: "> 100", unit: "mW", description: "Server and compute chips"),
                ]
            ),
            
            // Common Resistance Values
            ReferenceTable(
                title: "Common Resistor Values (E12 Series)",
                category: "Resistance",
                items: [
                    ReferenceItem(name: "10Ω", value: "10", unit: "Ω", description: nil),
                    ReferenceItem(name: "12Ω", value: "12", unit: "Ω", description: nil),
                    ReferenceItem(name: "15Ω", value: "15", unit: "Ω", description: nil),
                    ReferenceItem(name: "18Ω", value: "18", unit: "Ω", description: nil),
                    ReferenceItem(name: "22Ω", value: "22", unit: "Ω", description: nil),
                    ReferenceItem(name: "27Ω", value: "27", unit: "Ω", description: nil),
                    ReferenceItem(name: "33Ω", value: "33", unit: "Ω", description: nil),
                    ReferenceItem(name: "39Ω", value: "39", unit: "Ω", description: nil),
                    ReferenceItem(name: "47Ω", value: "47", unit: "Ω", description: nil),
                    ReferenceItem(name: "56Ω", value: "56", unit: "Ω", description: nil),
                    ReferenceItem(name: "68Ω", value: "68", unit: "Ω", description: nil),
                    ReferenceItem(name: "82Ω", value: "82", unit: "Ω", description: nil),
                ]
            ),
            
            // Common Capacitor Values
            ReferenceTable(
                title: "Common Capacitor Values",
                category: "Capacitance",
                items: [
                    ReferenceItem(name: "1pF", value: "1", unit: "pF", description: "RF tuning capacitor"),
                    ReferenceItem(name: "10pF", value: "10", unit: "pF", description: "Crystal load capacitance"),
                    ReferenceItem(name: "100pF", value: "100", unit: "pF", description: "Common bypass capacitor"),
                    ReferenceItem(name: "1nF", value: "1", unit: "nF", description: "Filtering and decoupling"),
                    ReferenceItem(name: "10nF", value: "10", unit: "nF", description: "Standard bypass capacitor"),
                    ReferenceItem(name: "100nF", value: "100", unit: "nF", description: "Most common bypass value"),
                    ReferenceItem(name: "1μF", value: "1", unit: "μF", description: "General purpose filtering"),
                    ReferenceItem(name: "10μF", value: "10", unit: "μF", description: "Bulk capacitance"),
                ]
            ),
            
            // Signal Integrity Standards
            ReferenceTable(
                title: "Signal Integrity Standards",
                category: "Signal Integrity",
                items: [
                    ReferenceItem(name: "Setup Time", value: "typically", unit: "< period/4", description: "Time before clock edge data must be stable"),
                    ReferenceItem(name: "Hold Time", value: "typically", unit: "< period/4", description: "Time after clock edge data must remain stable"),
                    ReferenceItem(name: "Rise Time (3.3V)", value: "1 - 10", unit: "ns", description: "Time to transition from low to high"),
                    ReferenceItem(name: "Fall Time (3.3V)", value: "1 - 10", unit: "ns", description: "Time to transition from high to low"),
                ]
            ),
        ]
    }
}
