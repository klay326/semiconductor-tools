//
//  ReferenceTablesView.swift
//  semiconductor tools
//
//  Created by Klay Adams on 12/23/25.
//

import SwiftUI

struct ReferenceTablesView: View {
    @StateObject private var dataStore = ReferenceTablesDataStore()
    @State private var searchText = ""
    
    var filteredTables: [ReferenceTable] {
        if searchText.isEmpty {
            return dataStore.tables
        }
        return dataStore.tables.filter { table in
            table.title.localizedCaseInsensitiveContains(searchText) ||
            table.items.contains { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.value.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Tables List
                if filteredTables.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Results")
                            .font(.headline)
                        Text("Try searching for a different term")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredTables) { table in
                            Section(header: Text(table.title).font(.headline)) {
                                ForEach(table.items) { item in
                                    NavigationLink(destination: ReferenceItemDetailView(item: item, tableName: table.title)) {
                                        ReferenceItemRow(item: item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reference Tables")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReferenceItemRow: View {
    let item: ReferenceItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 4) {
                    Text(item.value)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text(item.unit)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            if let description = item.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ReferenceItemDetailView: View {
    let item: ReferenceItem
    let tableName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(tableName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Value Card
                VStack(spacing: 12) {
                    Text("Value")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text(item.value)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        Text(item.unit)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Description
                if let description = item.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search tables...", text: $text)
                .textFieldStyle(.roundedBorder)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ReferenceTablesView()
}
