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
    private let usersListViewModel: UsersListViewModel

    init() {
        self.usersListViewModel = UsersListViewModel(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            UsersListView(
                viewModel: usersListViewModel,
                makeDetailViewModel: { UserDetailViewModel(userID: $0, repository: repository) }
            )
        }
    }
}
