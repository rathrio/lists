//
//  ListsView.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import SwiftUI

struct ListsView: View {
    @StateObject private var viewModel = ListsViewModel()

    var body: some View {
        TabView {
            ForEach(ListModel.defaultLists) { list in
                ItemListView(list: list)
                    .tabItem {
                        Image(systemName: systemIconName(for: list.faIcon))
                        Text(list.name)
                    }
                    .tag(list.id)
            }
        }
        .preferredColorScheme(.dark)
        .accentColor(.themeRed)
        .environmentObject(viewModel)
    }

    private func systemIconName(for faIcon: String) -> String {
        switch faIcon {
        case "film": return "film"
        case "tv": return "tv"
        case "music": return "music.note"
        case "gamepad": return "gamecontroller"
        case "book": return "book"
        default: return "list.bullet"
        }
    }
}

struct ItemListView: View {
    let list: ListModel
    @EnvironmentObject var viewModel: ListsViewModel
    @State private var searchText = ""

    private var filteredItems: [ItemModel] {
        let listItems = viewModel.items.filter { $0.listId == list.id }
        if searchText.isEmpty {
            return listItems
        } else {
            return listItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading...")
                        .foregroundColor(.themeForeground)
                } else if filteredItems.isEmpty {
                    EmptyStateView(list: list)
                } else {
                    ItemGridView(items: filteredItems)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .background(Color.themeDarkBackground)
            .searchable(text: $searchText)
            .refreshable {
                viewModel.loadItems(for: list.id)
            }
            .onAppear {
                if viewModel.selectedList?.id != list.id {
                    viewModel.selectList(list)
                }
            }
        }
        .background(Color.themeDarkBackground)
    }
}

struct EmptyStateView: View {
    let list: ListModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemIconName(for: list.faIcon))
                .font(.system(size: 60))
                .foregroundColor(.themePlaceholder)

            Text("No \(list.name.lowercased()) found")
                .font(.title2)
                .foregroundColor(.themeForeground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeDarkBackground)
    }

    private func systemIconName(for faIcon: String) -> String {
        switch faIcon {
        case "film": return "film"
        case "tv": return "tv"
        case "music": return "music.note"
        case "gamepad": return "gamecontroller"
        case "book": return "book"
        default: return "list.bullet"
        }
    }
}

struct ItemGridView: View {
    let items: [ItemModel]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(items) { item in
                    ItemCard(item: item)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .background(Color.themeDarkBackground)
    }

    private var columns: [GridItem] {
        // 3 equal columns with minimal spacing
        return Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    }
}

struct ItemCard: View {
    let item: ItemModel
    @EnvironmentObject var viewModel: ListsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // FIXED SIZE image container with proper aspect ratios
            ZStack {
                // Fixed size background with correct aspect ratio
                Rectangle()
                    .fill(Color.themeLightBackground)
                    .frame(width: imageWidth, height: imageHeight)

                // Image that fills container without stretching
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Fill without stretching
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped() // Crop overflow
                    case .failure(_), .empty:
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.themePlaceholder)
                            Text(item.name)
                                .font(.caption2)
                                .foregroundColor(.themeForeground)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 4)
                        }
                        .frame(width: imageWidth, height: imageHeight)
                    @unknown default:
                        ProgressView()
                            .frame(width: imageWidth, height: imageHeight)
                    }
                }

                // Status dot
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                            .padding(6)
                    }
                    Spacer()
                }
            }
            .cornerRadius(6)
            .onTapGesture {
                viewModel.toggleItemStatus(item)
            }

            // Year and rating - positioned exactly like the image
            HStack {
                if let year = item.year {
                    Text(String(year))
                        .font(.caption2)
                        .foregroundColor(.themeForeground)
                }

                Spacer()

                if let rating = item.rating, rating > 0 {
                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                .font(.system(size: 8))
                                .foregroundColor(.themeYellow)
                        }
                    }
                }
            }
            .frame(width: imageWidth, height: 16) // Exact same width and fixed height
        }
        .frame(width: imageWidth) // Force the entire card to be exactly image width
    }

    private var imageURL: URL? {
        guard let urlString = item.image?.thumb?.url ?? item.image?.url else { return nil }
        return URL(string: "http://localhost:3000\(urlString)")
    }

    // Fixed dimensions based on aspect ratios from React app
    private var imageWidth: CGFloat {
        return 110 // Base width for all types
    }

    private var imageHeight: CGFloat {
        switch item.list {
        case "Music":
            return 110 // 1:1 ratio (square)
        case "Games":
            return 147 // 3:4 ratio (110 * 4/3 = 146.67)
        default:
            return 165 // 2:3 ratio (110 * 3/2 = 165)
        }
    }

    private var statusColor: Color {
        switch item.status {
        case .todo: return .themePlaceholder
        case .doing: return .themeBlue
        case .done: return .themeRed
        }
    }
}

#Preview {
    ListsView()
}