//
//  UserDetailViewModelTests.swift
//  UsersFlowTests
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import Foundation
import Testing
@testable import UsersFlow

@MainActor
struct UserDetailViewModelTests {
    @Test
    func successfulLoadUpdatesUserAndDerivedContent() async throws {
        let expectedUser = makeUser(id: 7, firstName: "Alex", lastName: "Brown")
        let service = MockUsersService(
            userResult: .success(expectedUser),
            logs: [makeLogEntry(message: "Loaded user details from mock service")]
        )
        let viewModel = UserDetailViewModel(userID: expectedUser.id, usersService: service)

        await viewModel.reload()

        #expect(viewModel.user == expectedUser)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.profileContent?.fullName == expectedUser.fullName)
        #expect(viewModel.profileContent?.email == expectedUser.email)
        #expect(viewModel.detailsContent?.rows.count == 5)

        let fetchedUserIDs = await service.fetchedUserIDs
        #expect(fetchedUserIDs == [expectedUser.id])
    }

    @Test
    func failedLoadShowsErrorAndKeepsUserEmpty() async throws {
        let service = MockUsersService(
            userResult: .failure(MockServiceError.offline),
            logs: [makeLogEntry(message: "Failed to load user details")]
        )
        let viewModel = UserDetailViewModel(userID: 42, usersService: service)
        viewModel.user = makeUser(id: 42, firstName: "Stale", lastName: "User")

        await viewModel.reload()

        #expect(viewModel.user == nil)
        #expect(viewModel.errorMessage == MockServiceError.offline.localizedDescription)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.profileContent == nil)
        #expect(viewModel.detailsContent == nil)
    }

    @Test
    func initialStateIsEmptyBeforeLoading() async throws {
        let service = MockUsersService()
        let viewModel = UserDetailViewModel(userID: 123, usersService: service)

        #expect(viewModel.user == nil)
        #expect(viewModel.profileContent == nil)
        #expect(viewModel.detailsContent == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)

        let fetchedUserIDs = await service.fetchedUserIDs
        #expect(fetchedUserIDs.isEmpty)
    }
}
