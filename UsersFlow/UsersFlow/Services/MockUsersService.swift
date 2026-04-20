//
//  MockUsersService.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import Foundation

actor MockUsersService: UsersService {
    struct FetchRequest: Equatable, Sendable {
        let query: String
        let limit: Int
        let skip: Int
    }

    private let usersResult: Result<UsersPage<UserPreview>, Error>
    private let userResult: Result<User, Error>
    private let logs: [UsersCache.LogEntry]
    private(set) var fetchRequests: [FetchRequest] = []
    private(set) var fetchedUserIDs: [Int] = []
    private(set) var prefetchedIDs: [[Int]] = []

    init(
        usersResult: Result<UsersPage<UserPreview>, Error> = .success(.init(users: [], total: 0, skip: 0, limit: 20)),
        userResult: Result<User, Error> = .failure(MockUsersServiceError.unimplementedUser),
        logs: [UsersCache.LogEntry] = []
    ) {
        self.usersResult = usersResult
        self.userResult = userResult
        self.logs = logs
    }

    func fetchUsers(query: String, limit: Int, skip: Int) async throws -> UsersPage<UserPreview> {
        fetchRequests.append(.init(query: query, limit: limit, skip: skip))
        return try usersResult.get()
    }

    func fetchUser(id: Int) async throws -> User {
        fetchedUserIDs.append(id)
        return try userResult.get()
    }

    func prefetchUsers(ids: [Int]) async {
        prefetchedIDs.append(ids)
    }

    func cacheLogs(limit: Int) async -> [UsersCache.LogEntry] {
        Array(logs.prefix(limit))
    }
}

private enum MockUsersServiceError: LocalizedError {
    case unimplementedUser

    var errorDescription: String? {
        switch self {
        case .unimplementedUser:
            return "Mock user result was not configured."
        }
    }
}
