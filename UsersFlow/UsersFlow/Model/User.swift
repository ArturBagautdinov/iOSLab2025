//
//  User.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

nonisolated struct User: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let firstName: String
    let lastName: String
    let maidenName: String?
    let age: Int?
    let gender: String?
    let email: String
    let phone: String?
    let username: String?
    let birthDate: String?
    let image: URL?
    let university: String?
    let company: UserCompany?
    let address: UserAddress?
    let role: String?

    var fullName: String {
        [firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var locationLine: String {
        let parts = [address?.city, address?.state, address?.country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? "Location unavailable" : parts.joined(separator: ", ")
    }

    var companyLine: String {
        let parts = [company?.title, company?.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? "Independent profile" : parts.joined(separator: " at ")
    }
}

nonisolated struct UserCompany: Codable, Hashable, Sendable {
    let department: String?
    let name: String?
    let title: String?
}

nonisolated struct UserAddress: Codable, Hashable, Sendable {
    let address: String?
    let city: String?
    let state: String?
    let country: String?
}
