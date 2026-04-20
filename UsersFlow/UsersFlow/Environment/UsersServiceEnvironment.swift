//
//  UsersServiceEnvironment.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 20.04.2026.
//

import SwiftUI

private struct UsersServiceKey: EnvironmentKey {
    static let defaultValue: any UsersService = RealUsersService()
}

extension EnvironmentValues {
    var usersService: any UsersService {
        get { self[UsersServiceKey.self] }
        set { self[UsersServiceKey.self] = newValue }
    }
}
