//
//  UsersPreviewCache.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

actor UsersPreviewCache {
    private struct PageKey: Hashable, Sendable {
        let query: String
        let limit: Int
        let skip: Int
    }

    private var storage: [PageKey: UsersPage<UserPreview>] = [:]
    private var inFlight: [PageKey: Task<UsersPage<UserPreview>, Error>] = [:]
    private var logs: [UsersCache.LogEntry] = []
    private let logLimit = 30

    func recentLogs(limit: Int) -> [UsersCache.LogEntry] {
        Array(logs.suffix(limit).reversed())
    }

    func resolvePage(
        query: String,
        limit: Int,
        skip: Int,
        using loader: @escaping @Sendable () async throws -> UsersPage<UserPreview>
    ) async throws -> UsersPage<UserPreview> {
        let key = makeKey(query: query, limit: limit, skip: skip)

        if let cachedPage = storage[key] {
            appendLog("Served cached user list for query '\(displayQuery(query))'")
            return cachedPage
        }

        if let existingTask = inFlight[key] {
            appendLog("Joined existing list request for query '\(displayQuery(query))'")
            return try await existingTask.value
        }

        appendLog("Starting network request for user list '\(displayQuery(query))'")
        let task = Task<UsersPage<UserPreview>, Error> {
            let page = try await loader()
            self.finishLoading(page, for: key, query: query)
            return page
        }

        inFlight[key] = task

        do {
            return try await task.value
        } catch is CancellationError {
            inFlight[key] = nil
            appendLog("Cancelled list request for query '\(displayQuery(query))'")
            throw CancellationError()
        } catch {
            inFlight[key] = nil
            appendLog("Failed list request for query '\(displayQuery(query))': \(error.localizedDescription)")
            throw error
        }
    }

    private func finishLoading(_ page: UsersPage<UserPreview>, for key: PageKey, query: String) {
        storage[key] = page
        inFlight[key] = nil
        appendLog("Stored user list for query '\(displayQuery(query))' in memory")
    }

    private func makeKey(query: String, limit: Int, skip: Int) -> PageKey {
        PageKey(
            query: query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            limit: limit,
            skip: skip
        )
    }

    private func displayQuery(_ query: String) -> String {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedQuery.isEmpty ? "all users" : trimmedQuery
    }

    private func appendLog(_ message: String) {
        logs.append(.init(createdAt: .now, message: message))
        if logs.count > logLimit {
            logs.removeFirst(logs.count - logLimit)
        }
    }
}
