//
//  ProfileControllerWrapper.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import SwiftUI

struct ProfileControllerWrapper: UIViewControllerRepresentable {
    let profile: UserDetailViewModel.ProfileContent
    let isFollowing: Bool
    let onFollowTap: () -> Void

    func makeUIViewController(context: Context) -> ProfileViewController {
        let controller = ProfileViewController()
        controller.onFollowTap = onFollowTap
        return controller
    }

    func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
        uiViewController.onFollowTap = onFollowTap
        uiViewController.configure(
            with: .init(
                fullName: profile.fullName,
                email: profile.email,
                imageURL: profile.imageURL,
                isFollowing: isFollowing
            )
        )
    }
}
