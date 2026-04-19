//
//  UsersRepository.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

nonisolated struct UsersRepository: Sendable {
    private let apiClient: UsersAPIClient
    private let cache: UsersCache
    private let previewsCache: UsersPreviewCache
    private let limiter: RequestLimiter

    init(
        apiClient: UsersAPIClient = UsersAPIClient(),
        cache: UsersCache = UsersCache(),
        previewsCache: UsersPreviewCache = UsersPreviewCache(),
        limiter: RequestLimiter = RequestLimiter(maximumConcurrentRequests: 3)
    ) {
        self.apiClient = apiClient
        self.cache = cache
        self.previewsCache = previewsCache
        self.limiter = limiter
    }

    func fetchUsers(query: String, limit: Int = 20, skip: Int = 0) async throws -> UsersPage<UserPreview> {
        try await previewsCache.resolvePage(query: query, limit: limit, skip: skip) {
            try await apiClient.fetchUsers(limit: limit, skip: skip, query: query)
        }
    }

    func fetchUser(id: Int) async throws -> User {
        try await cache.resolveUser(for: id) {
            try Task.checkCancellation()
            await limiter.acquire()

            do {
                let user = try await apiClient.fetchUser(id: id)
                await limiter.release()
                return user
            } catch {
                await limiter.release()
                throw error
            }
        }
    }

    func prefetchUsers(ids: [Int]) async {
        await withTaskGroup(of: Void.self) { group in
            for id in ids {
                group.addTask { [self] in
                    guard !Task.isCancelled else { return }

                    do {
                        _ = try await fetchUser(id: id)
                    } catch is CancellationError {
                    } catch {
                    }
                }
            }
        }
    }

    func cacheLogs(limit: Int = 30) async -> [UsersCache.LogEntry] {
        async let userLogs = cache.recentLogs(limit: limit)
        async let previewLogs = previewsCache.recentLogs(limit: limit)

        let mergedLogs = await userLogs + previewLogs
        return Array(mergedLogs.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }
}
