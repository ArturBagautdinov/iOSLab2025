//
//  UserPreview.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

nonisolated struct UserPreview: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let image: URL?
    let company: CompanyPreview?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var primarySubtitle: String {
        email
    }

    var secondarySubtitle: String {
        "User ID #\(id)"
    }
}

nonisolated struct CompanyPreview: Codable, Hashable, Sendable {
    let title: String?
}

nonisolated struct UsersPage<Item: Codable & Sendable>: Codable, Sendable {
    let users: [Item]
    let total: Int
    let skip: Int
    let limit: Int
}
