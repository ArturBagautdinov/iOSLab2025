//
//  UsersListViewModel.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation
import Observation

@Observable
final class UsersListViewModel {
    let availableLimits = [10, 20, 30, 50, 80, 100, 150, 200]

    var users: [UserPreview] = []
    var cacheLogs: [UsersCache.LogEntry] = []
    var searchText = ""
    var errorMessage: String?
    var isLoading = false
    var isPrefetching = false
    var totalUsers = 0
    var selectedLimit = 20
    
    @ObservationIgnored private let repository: UsersRepository
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var prefetchTask: Task<Void, Never>?

    init(repository: UsersRepository) {
        self.repository = repository
    }

    func onAppear() {
        guard users.isEmpty, !isLoading else { return }
        loadUsers()
    }

    func onDisappear() {
        loadTask?.cancel()
        searchTask?.cancel()
        prefetchTask?.cancel()
    }

    func scheduleSearch() {
        searchTask?.cancel()
        let query = searchText

        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(350))
                try Task.checkCancellation()
                self?.loadUsers(query: query)
            } catch is CancellationError {
            } catch {
            }
        }
    }

    func reload() async {
        loadUsers()
        await loadTask?.value
    }

    func applySelectedLimit() {
        loadUsers()
    }

    func cancelPrefetch() {
        prefetchTask?.cancel()
        isPrefetching = false
    }

    private func loadUsers(query: String? = nil) {
        loadTask?.cancel()
        prefetchTask?.cancel()
        errorMessage = nil
        isLoading = true

        let currentQuery = query ?? searchText
        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let page = try await repository.fetchUsers(query: currentQuery, limit: selectedLimit)
                try Task.checkCancellation()

                users = page.users
                totalUsers = page.total
                isLoading = false
                await refreshCacheLogs()
                startPrefetch(for: Array(page.users.prefix(8).map(\.id)))
            } catch is CancellationError {
                isLoading = false
            } catch {
                isLoading = false
                users = []
                errorMessage = error.localizedDescription
                await refreshCacheLogs()
            }
        }
    }

    private func startPrefetch(for ids: [Int]) {
        guard !ids.isEmpty else { return }

        isPrefetching = true
        prefetchTask = Task { [weak self] in
            guard let self else { return }

            await repository.prefetchUsers(ids: ids)
            guard !Task.isCancelled else { return }

            isPrefetching = false
            await refreshCacheLogs()
        }
    }

    private func refreshCacheLogs() async {
        cacheLogs = await repository.cacheLogs()
    }
}
