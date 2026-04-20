//
//  UserDetailView.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Observation
import SwiftUI
import UIComponents

struct UserDetailView: View {
    @State private var viewModel: UserDetailViewModel

    init(viewModel: UserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        ScrollView {
            VStack(spacing: 20) {
                if bindableViewModel.user != nil {
                    if let profile = bindableViewModel.profileContent {
                        UIComponents.ProfileCardView(
                            viewData: .init(
                                fullName: profile.fullName,
                                email: profile.email,
                                imageURL: profile.imageURL,
                                isFollowing: bindableViewModel.isFollowing
                            ),
                            onFollowTap: {
                                bindableViewModel.toggleFollow()
                            }
                        )
                        .frame(height: 320)
                    }
                    if let details = bindableViewModel.detailsContent {
                        UserDetailsControllerWrapper(details: details)
                            .frame(height: 730)
                    }
                    CacheLogPanel(title: "Recent Cache Activity", logs: bindableViewModel.cacheLogs)
                } else if bindableViewModel.isLoading {
                    UIComponents.LoadingView(title: "Loading profile...", centersTitle: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 120)
                } else {
                    ContentUnavailableView(
                        "Profile unavailable",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text(bindableViewModel.errorMessage ?? "Something went wrong.")
                    )

                    Button("Try Again") {
                        bindableViewModel.retry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Color("DetailBackgroundTop"), Color("DetailBackgroundBottom")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(bindableViewModel.user?.fullName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            bindableViewModel.onAppear()
        }
        .onDisappear {
            bindableViewModel.onDisappear()
        }
    }
}
