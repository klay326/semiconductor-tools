//
//  HomeView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct ToolItem {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
}

struct HomeView: View {
    let tools: [ToolItem] = [
        ToolItem(
            id: "yield",
            name: "Yield Binning",
            icon: "chart.bar.fill",
            color: .blue,
            description: "Track wafer yields with custom bins"
        ),
        ToolItem(
            id: "parametric",
            name: "Parametric Specs",
            icon: "slider.horizontal.3",
            color: .purple,
            description: "Define and monitor test specs"
        ),
        ToolItem(
            id: "statistics",
            name: "Statistics",
            icon: "chart.bar",
            color: .green,
            description: "Calculate mean, std dev, Cpk/Ppk"
        ),
        ToolItem(
            id: "testtime",
            name: "Test Time",
            icon: "clock.badge.checkmark",
            color: .orange,
            description: "Estimate test time & throughput"
        ),
        ToolItem(
            id: "period",
            name: "Period/Frequency",
            icon: "waveform.circle",
            color: .red,
            description: "Convert between periods and frequencies"
        ),
        ToolItem(
            id: "reference",
            name: "Reference",
            icon: "book.fill",
            color: .cyan,
            description: "Common semiconductor values"
        ),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Semiconductor Tools")
                                .font(.system(size: 32, weight: .bold, design: .default))
                            Text("Product Test Engineer's Toolkit")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Grid of tools
                        VStack(spacing: 16) {
                            ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                                if index % 2 == 0 {
                                    HStack(spacing: 16) {
                                        ToolCardView(tool: tools[index])
                                        
                                        if index + 1 < tools.count {
                                            ToolCardView(tool: tools[index + 1])
                                        } else {
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ToolCardView: View {
    let tool: ToolItem
    @State private var showDestination = false
    
    var body: some View {
        NavigationLink(destination: toolDestination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tool.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(tool.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(16)
            .background(tool.color)
            .cornerRadius(12)
            .frame(height: 160)
        }
    }
    
    @ViewBuilder
    private var toolDestination: some View {
        switch tool.id {
        case "yield":
            EnhancedYieldCalculatorView()
        case "parametric":
            ParametricSpecCalculatorView()
        case "statistics":
            StatisticalAnalysisView()
        case "testtime":
            TestTimeCalculatorView()
        case "period":
            PeriodFrequencyCalculatorView()
        case "reference":
            ReferenceTablesView()
        default:
            Text("Unknown Tool")
        }
    }
}

#Preview {
    HomeView()
}
