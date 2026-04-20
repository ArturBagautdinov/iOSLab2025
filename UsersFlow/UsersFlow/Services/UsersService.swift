//
//  UsersService.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import Foundation

nonisolated protocol UsersService: Sendable {
    func fetchUsers(query: String, limit: Int, skip: Int) async throws -> UsersPage<UserPreview>
    func fetchUser(id: Int) async throws -> User
    func prefetchUsers(ids: [Int]) async
    func cacheLogs(limit: Int) async -> [UsersCache.LogEntry]
}
