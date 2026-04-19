//
//  UsersCaching.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

protocol UsersCaching: Actor {
    func user(for id: Int) -> User?
    func save(_ user: User)
}
