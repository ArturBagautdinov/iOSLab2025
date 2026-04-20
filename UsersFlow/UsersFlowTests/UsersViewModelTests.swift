//
//  UsersViewModelTests.swift
//  UsersFlowTests
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import Foundation
import Testing
@testable import UsersFlow

@MainActor
struct UsersViewModelTests {
    @Test
    func successfulLoadUpdatesUsers() async throws {
        let expectedUsers = [
            makeUserPreview(id: 1, firstName: "John", lastName: "Appleseed"),
            makeUserPreview(id: 2, firstName: "Jane", lastName: "Doe")
        ]
        let service = MockUsersService(
            usersResult: .success(
                UsersPage(
                    users: expectedUsers,
                    total: expectedUsers.count,
                    skip: 0,
                    limit: 20
                )
            ),
            logs: [makeLogEntry(message: "Loaded users from mock service")]
        )
        let viewModel = UsersListViewModel(usersService: service)

        await viewModel.reload()

        #expect(viewModel.users == expectedUsers)
        #expect(viewModel.totalUsers == expectedUsers.count)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.cacheLogs.count == 1)

        let requests = await service.fetchRequests
        #expect(requests == [.init(query: "", limit: 20, skip: 0)])
    }

    @Test
    func failedLoadShowsErrorAndClearsUsers() async throws {
        let service = MockUsersService(
            usersResult: .failure(MockServiceError.offline),
            logs: [makeLogEntry(message: "Failed to load users")]
        )
        let viewModel = UsersListViewModel(usersService: service)
        viewModel.users = [makeUserPreview(id: 99, firstName: "Old", lastName: "User")]
        viewModel.totalUsers = 1

        await viewModel.reload()

        #expect(viewModel.users.isEmpty)
        #expect(viewModel.totalUsers == 0)
        #expect(viewModel.errorMessage == MockServiceError.offline.localizedDescription)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.cacheLogs.count == 1)
    }

    @Test
    func emptyLoadKeepsEmptyStateWithoutError() async throws {
        let service = MockUsersService(
            usersResult: .success(
                UsersPage(
                    users: [],
                    total: 0,
                    skip: 0,
                    limit: 20
                )
            )
        )
        let viewModel = UsersListViewModel(usersService: service)

        await viewModel.reload()

        #expect(viewModel.users.isEmpty)
        #expect(viewModel.totalUsers == 0)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isPrefetching == false)

        let prefetchedIDs = await service.prefetchedIDs
        #expect(prefetchedIDs.isEmpty)
    }
}

enum MockServiceError: LocalizedError {
    case offline

    var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection."
        }
    }
}

func makeUserPreview(id: Int, firstName: String, lastName: String) -> UserPreview {
    UserPreview(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: "\(firstName.lowercased())@example.com",
        image: nil,
        company: CompanyPreview(title: "iOS Team")
    )
}

func makeUser(id: Int, firstName: String, lastName: String) -> User {
    User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        maidenName: nil,
        age: 28,
        gender: "non-binary",
        email: "\(firstName.lowercased())@example.com",
        phone: "+1 555 123 4567",
        username: firstName.lowercased(),
        birthDate: "1998-10-15",
        image: nil,
        university: "Swift University",
        company: UserCompany(department: "Engineering", name: "UsersFlow", title: "iOS Developer"),
        address: UserAddress(address: "1 Infinite Loop", city: "Cupertino", state: "CA", country: "USA"),
        role: "admin"
    )
}

func makeLogEntry(message: String) -> UsersCache.LogEntry {
    UsersCache.LogEntry(createdAt: .now, message: message)
}
