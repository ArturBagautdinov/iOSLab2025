//
//  RealUsersService.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import Foundation

nonisolated struct RealUsersService: UsersService {
    private let repository: UsersRepository

    init(repository: UsersRepository = UsersRepository()) {
        self.repository = repository
    }

    func fetchUsers(query: String, limit: Int, skip: Int) async throws -> UsersPage<UserPreview> {
        try await repository.fetchUsers(query: query, limit: limit, skip: skip)
    }

    func fetchUser(id: Int) async throws -> User {
        try await repository.fetchUser(id: id)
    }

    func prefetchUsers(ids: [Int]) async {
        await repository.prefetchUsers(ids: ids)
    }

    func cacheLogs(limit: Int) async -> [UsersCache.LogEntry] {
        await repository.cacheLogs(limit: limit)
    }
}
