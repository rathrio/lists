//
//  Models.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import Foundation

// MARK: - ListModel
struct ListModel: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let scraper: String?
    let faIcon: String
    let createdAt: String
    let updatedAt: String
    let userId: Int
    let coverAspectRatio: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, scraper
        case faIcon = "fa_icon"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
        case coverAspectRatio = "cover_aspect_ratio"
    }

    // Static data for the 5 default lists to match the backend
    static let defaultLists: [ListModel] = [
        ListModel(id: 1, name: "Movies", description: nil, scraper: "MovieScraper", faIcon: "film", createdAt: "", updatedAt: "", userId: 1, coverAspectRatio: "2by3"),
        ListModel(id: 2, name: "TV", description: nil, scraper: "TvScraper", faIcon: "tv", createdAt: "", updatedAt: "", userId: 1, coverAspectRatio: "2by3"),
        ListModel(id: 3, name: "Music", description: nil, scraper: "AlbumScraper", faIcon: "music", createdAt: "", updatedAt: "", userId: 1, coverAspectRatio: "1by1"),
        ListModel(id: 4, name: "Games", description: nil, scraper: "GameScraper", faIcon: "gamepad", createdAt: "", updatedAt: "", userId: 1, coverAspectRatio: "3by4"),
        ListModel(id: 5, name: "Books", description: nil, scraper: "BookScraper", faIcon: "book", createdAt: "", updatedAt: "", userId: 1, coverAspectRatio: "2by3")
    ]
}

// MARK: - ItemStatus
enum ItemStatus: String, Codable, CaseIterable {
    case todo = "todo"
    case doing = "doing"
    case done = "done"

    var displayName: String {
        switch self {
        case .todo: return "To Watch"
        case .doing: return "Watching"
        case .done: return "Watched"
        }
    }

    var next: ItemStatus {
        switch self {
        case .todo: return .doing
        case .doing: return .done
        case .done: return .todo
        }
    }
}

// MARK: - ItemImage
struct ItemImage: Codable {
    let url: String?
    let thumb: ItemImageThumb?
}

struct ItemImageThumb: Codable {
    let url: String?
}

// MARK: - ItemModel
struct ItemModel: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let quantity: Int?
    let scraped: Bool?
    let date: String?
    let createdAt: String
    let updatedAt: String
    let image: ItemImage?
    let deletedAt: String?
    let userId: Int
    let listId: Int
    let status: ItemStatus
    let rating: Double?
    let recommendedBy: String?
    let firstDoneAt: String?
    let language: String?
    let originalName: String?
    let backdropImage: ItemImage?
    let notes: String?
    let tags: [String]
    let list: String
    let faIcon: String
    let year: Int?
    let deleted: Bool
    let humanStatus: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, quantity, scraped, date, image, notes, tags, list, year, deleted, status, rating, language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case userId = "user_id"
        case listId = "list_id"
        case recommendedBy = "recommended_by"
        case firstDoneAt = "first_done_at"
        case originalName = "original_name"
        case backdropImage = "backdrop_image"
        case faIcon = "fa_icon"
        case humanStatus = "human_status"
    }
}