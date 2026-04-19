//
//  UserDetailsControllerWrapper.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import SwiftUI

struct UserDetailsControllerWrapper: UIViewControllerRepresentable {
    let details: UserDetailViewModel.DetailsContent

    func makeUIViewController(context: Context) -> UserDetailsViewController {
        UserDetailsViewController()
    }

    func updateUIViewController(_ uiViewController: UserDetailsViewController, context: Context) {
        uiViewController.configure(
            with: .init(
                rows: details.rows.map {
                    .init(title: $0.title, value: $0.value)
                }
            )
        )
    }
}
