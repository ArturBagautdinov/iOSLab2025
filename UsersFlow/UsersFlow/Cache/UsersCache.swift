//
//  UsersCache.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

actor UsersCache: UsersCaching {
    struct LogEntry: Identifiable, Hashable, Sendable {
        let id = UUID()
        let createdAt: Date
        let message: String
    }

    private var storage: [Int: User] = [:]
    private var inFlight: [Int: Task<User, Error>] = [:]
    private var logs: [LogEntry] = []
    private let logLimit = 30

    func user(for id: Int) -> User? {
        if let user = storage[id] {
            appendLog("Cache hit for user #\(id)")
            return user
        }

        appendLog("Cache miss for user #\(id)")
        return nil
    }

    func save(_ user: User) {
        storage[user.id] = user
        appendLog("Saved user #\(user.id) to in-memory cache")
    }

    func recentLogs(limit: Int) -> [LogEntry] {
        Array(logs.suffix(limit).reversed())
    }

    func resolveUser(
        for id: Int,
        using loader: @escaping @Sendable () async throws -> User
    ) async throws -> User {
        if let cachedUser = storage[id] {
            appendLog("Served cached user #\(id)")
            return cachedUser
        }

        if let existingTask = inFlight[id] {
            appendLog("Joined existing request for user #\(id)")
            return try await existingTask.value
        }

        appendLog("Starting network request for user #\(id)")
        let task = Task<User, Error> {
            let loadedUser = try await loader()
            self.finishLoading(loadedUser)
            return loadedUser
        }

        inFlight[id] = task

        do {
            return try await task.value
        } catch is CancellationError {
            inFlight[id] = nil
            appendLog("Cancelled request for user #\(id)")
            throw CancellationError()
        } catch {
            inFlight[id] = nil
            appendLog("Failed request for user #\(id): \(error.localizedDescription)")
            throw error
        }
    }

    private func finishLoading(_ user: User) {
        storage[user.id] = user
        inFlight[user.id] = nil
        appendLog("Stored network response for user #\(user.id)")
    }

    private func appendLog(_ message: String) {
        logs.append(LogEntry(createdAt: .now, message: message))
        if logs.count > logLimit {
            logs.removeFirst(logs.count - logLimit)
        }
    }
}
