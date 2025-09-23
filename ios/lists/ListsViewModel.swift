//
//  ListsViewModel.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import Foundation
import Combine

class ListsViewModel: ObservableObject {
    @Published var lists: [ListModel] = []
    @Published var items: [ItemModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedList: ListModel?

    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared

    init() {
        loadLists()
    }

    func loadLists() {
        isLoading = true
        errorMessage = nil

        networkManager.fetchLists()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                            // Fallback to default lists if API fails
                            self?.lists = ListModel.defaultLists
                        }
                    }
                },
                receiveValue: { [weak self] lists in
                    DispatchQueue.main.async {
                        self?.lists = lists
                        if let firstList = lists.first {
                            self?.selectList(firstList)
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }

    func selectList(_ list: ListModel) {
        selectedList = list
        loadItems(for: list.id)
    }

    func loadItems(for listId: Int) {
        isLoading = true
        errorMessage = nil

        networkManager.fetchItems(for: listId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] items in
                    DispatchQueue.main.async {
                        self?.items = items
                    }
                }
            )
            .store(in: &cancellables)
    }

    func toggleItemStatus(_ item: ItemModel) {
        networkManager.toggleItemStatus(itemId: item.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] updatedItem in
                    DispatchQueue.main.async {
                        if let index = self?.items.firstIndex(where: { $0.id == updatedItem.id }) {
                            self?.items[index] = updatedItem
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
}