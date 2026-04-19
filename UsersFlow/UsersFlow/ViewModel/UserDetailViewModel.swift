//
//  UserDetailViewModel.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation
import Observation

@Observable
final class UserDetailViewModel {
    struct ProfileContent: Equatable, Sendable {
        let fullName: String
        let email: String
        let imageURL: URL?
    }

    struct DetailsContent: Equatable, Sendable {
        struct Row: Equatable, Sendable {
            let title: String
            let value: String
        }

        let rows: [Row]
    }

    var user: User?
    var cacheLogs: [UsersCache.LogEntry] = []
    var errorMessage: String?
    var isLoading = false
    var isFollowing = false

    @ObservationIgnored private let repository: UsersRepository
    @ObservationIgnored private let userID: Int
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    init(userID: Int, repository: UsersRepository) {
        self.userID = userID
        self.repository = repository
    }

    var profileContent: ProfileContent? {
        guard let user else { return nil }
        return ProfileContent(
            fullName: user.fullName,
            email: user.email,
            imageURL: user.image
        )
    }

    var detailsContent: DetailsContent? {
        guard let user else { return nil }
        return DetailsContent(
            rows: [
                .init(
                    title: "Account",
                    value: [
                        "User ID: \(user.id)",
                        "Username: \(user.username ?? "Not provided")",
                        "Role: \(user.role ?? "Not provided")"
                    ].joined(separator: "\n")
                ),
                .init(
                    title: "Personal",
                    value: [
                        "First name: \(user.firstName)",
                        "Last name: \(user.lastName)",
                        "Maiden name: \(user.maidenName ?? "Not provided")",
                        "Age: \(user.age.map(String.init) ?? "Not provided")",
                        "Gender: \(user.gender ?? "Not provided")",
                        "Birth date: \(user.birthDate ?? "Not provided")"
                    ].joined(separator: "\n")
                ),
                .init(
                    title: "Contact",
                    value: [
                        "Email: \(user.email)",
                        "Phone: \(user.phone ?? "Not provided")"
                    ].joined(separator: "\n")
                ),
                .init(
                    title: "Work",
                    value: [
                        "Company: \(user.companyLine)",
                        "Department: \(user.company?.department ?? "Not provided")",
                        "University: \(user.university ?? "Not provided")"
                    ].joined(separator: "\n")
                ),
                .init(
                    title: "Address",
                    value: [
                        "Street: \(user.address?.address ?? "Not provided")",
                        "Location: \(user.locationLine)"
                    ].joined(separator: "\n")
                )
            ]
        )
    }

    func onAppear() {
        guard user == nil, !isLoading else { return }
        load()
    }

    func onDisappear() {
        loadTask?.cancel()
    }

    func retry() {
        load()
    }

    func toggleFollow() {
        isFollowing.toggle()
    }

    private func load() {
        loadTask?.cancel()
        errorMessage = nil
        isLoading = true

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let loadedUser = try await repository.fetchUser(id: userID)
                try Task.checkCancellation()

                user = loadedUser
                isLoading = false
                await refreshCacheLogs()
            } catch is CancellationError {
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                await refreshCacheLogs()
            }
        }
    }

    private func refreshCacheLogs() async {
        cacheLogs = await repository.cacheLogs(limit: 8)
    }
}
