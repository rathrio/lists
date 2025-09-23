//
//  NetworkManager.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    private let baseURL = "http://localhost:3000"
    private let session = URLSession.shared

    private init() {}

    // MARK: - Lists API
    func fetchLists() -> AnyPublisher<[ListModel], Error> {
        guard let url = URL(string: "\(baseURL)/lists") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ListModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Items API
    func fetchItems(for listId: Int) -> AnyPublisher<[ItemModel], Error> {
        guard let url = URL(string: "\(baseURL)/lists/\(listId)/items") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ItemModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Item Actions
    func toggleItemStatus(itemId: Int) -> AnyPublisher<ItemModel, Error> {
        guard let url = URL(string: "\(baseURL)/items/\(itemId)/toggle_status") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ItemModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}