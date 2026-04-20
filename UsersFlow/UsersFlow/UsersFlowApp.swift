//
//  UsersFlowApp.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import SwiftUI

@main
struct UsersFlowApp: App {
    private let repository = UsersRepository()
    private let usersService: RealUsersService
    private let usersListViewModel: UsersListViewModel

    init() {
        self.usersService = RealUsersService(repository: repository)
        self.usersListViewModel = UsersListViewModel(usersService: usersService)
    }

    var body: some Scene {
        WindowGroup {
            UsersListView(
                viewModel: usersListViewModel,
                makeDetailViewModel: { UserDetailViewModel(userID: $0, usersService: usersService) }
            )
            .environment(\.usersService, usersService)
        }
    }
}
