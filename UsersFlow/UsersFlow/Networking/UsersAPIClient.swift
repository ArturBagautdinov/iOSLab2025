//
//  UsersAPIClient.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

nonisolated struct UsersAPIClient: Sendable {
    private let baseURL = URL(string: "https://dummyjson.com")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUsers(limit: Int, skip: Int, query: String) async throws -> UsersPage<UserPreview> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpoint = trimmedQuery.isEmpty ? "/users" : "/users/search"
        var components = URLComponents(url: baseURL.appending(path: endpoint), resolvingAgainstBaseURL: false)

        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]

        if trimmedQuery.isEmpty {
            queryItems.append(
                URLQueryItem(
                    name: "select",
                    value: "firstName,lastName,email,image,company.title"
                )
            )
        } else {
            queryItems.append(URLQueryItem(name: "q", value: trimmedQuery))
        }

        components?.queryItems = queryItems
        let request = try makeRequest(from: components)
        return try await decode(UsersPage<UserPreview>.self, from: request)
    }

    func fetchUser(id: Int) async throws -> User {
        var components = URLComponents(url: baseURL.appending(path: "/users/\(id)"), resolvingAgainstBaseURL: false)
        components?.queryItems = []
        let request = try makeRequest(from: components)
        return try await decode(User.self, from: request)
    }

    private func makeRequest(from components: URLComponents?) throws -> URLRequest {
        guard let url = components?.url else {
            throw UsersAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        return request
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsersAPIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw UsersAPIError.httpError(code: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw UsersAPIError.decodingFailed
        }
    }
}

nonisolated enum UsersAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(code: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to build the DummyJSON request."
        case .invalidResponse:
            return "Received an invalid server response."
        case .httpError(let code):
            return "DummyJSON returned HTTP \(code)."
        case .decodingFailed:
            return "Failed to decode the users payload."
        }
    }
}
