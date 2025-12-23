//
//  PeriodFrequencyCalculatorView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct PeriodFrequencyCalculatorView: View {
    @State private var calculationMode: CalcMode = .periodToFreq
    @State private var periodValue = ""
    @State private var frequencyValue = ""
    @State private var selectedTimeUnit: TimeUnit = .nanoseconds
    @State private var selectedFrequencyUnit: FrequencyUnit = .mhz
    
    enum CalcMode {
        case periodToFreq
        case freqToPeriod
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Mode Picker
                Picker("Calculation Mode", selection: $calculationMode) {
                    Text("Period → Frequency").tag(CalcMode.periodToFreq)
                    Text("Frequency → Period").tag(CalcMode.freqToPeriod)
                }
                .pickerStyle(.segmented)
                .padding()
                
                VStack(spacing: 20) {
                    if calculationMode == .periodToFreq {
                        // Period Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                TextField("Enter period", text: $periodValue)
                                    .keyboardType(.decimalPad)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Picker("Unit", selection: $selectedTimeUnit) {
                                    ForEach(TimeUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .frame(width: 80)
                            }
                        }
                        
                        // Arrow
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.down")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        
                        // Frequency Output
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Text(frequencyFromPeriod)
                                    .font(.system(.title3, design: .monospaced))
                                    .fontWeight(.semibold)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Picker("Unit", selection: $selectedFrequencyUnit) {
                                    ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .frame(width: 80)
                            }
                        }
                    } else {
                        // Frequency Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                TextField("Enter frequency", text: $frequencyValue)
                                    .keyboardType(.decimalPad)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Picker("Unit", selection: $selectedFrequencyUnit) {
                                    ForEach(FrequencyUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .frame(width: 80)
                            }
                        }
                        
                        // Arrow
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.down")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        
                        // Period Output
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Period")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Text(periodFromFrequency)
                                    .font(.system(.title3, design: .monospaced))
                                    .fontWeight(.semibold)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Picker("Unit", selection: $selectedTimeUnit) {
                                    ForEach(TimeUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .frame(width: 80)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Spacer()
            }
            .navigationTitle("Period/Frequency")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var frequencyFromPeriod: String {
        guard let period = Double(periodValue), period > 0 else {
            return "—"
        }
        let periodInSeconds = period * selectedTimeUnit.toSeconds
        let frequencyInHz = 1.0 / periodInSeconds
        let frequency = frequencyInHz / selectedFrequencyUnit.divisor
        return String(format: "%.6g", frequency)
    }
    
    var periodFromFrequency: String {
        guard let freq = Double(frequencyValue), freq > 0 else {
            return "—"
        }
        let frequencyInHz = freq * selectedFrequencyUnit.divisor
        let periodInSeconds = 1.0 / frequencyInHz
        let period = periodInSeconds / selectedTimeUnit.toSeconds
        return String(format: "%.6g", period)
    }
}

#Preview {
    PeriodFrequencyCalculatorView()
}
