//
//  ContentView.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Observation
import SwiftUI
import UIComponents

struct UsersListView: View {
    @Environment(\.colorScheme) private var colorScheme

    let viewModel: UsersListViewModel
    let makeDetailViewModel: (Int) -> UserDetailViewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color("ListBackgroundTop"), Color("ListBackgroundMiddle"), Color("ListBackgroundBottom")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        heroSection(bindableViewModel: $viewModel)

                        if let errorMessage = viewModel.errorMessage, viewModel.users.isEmpty {
                            ContentUnavailableView(
                                "Users failed to load",
                                systemImage: "wifi.exclamationmark",
                                description: Text(errorMessage)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else if viewModel.isLoading && viewModel.users.isEmpty {
                            loadingSection
                        } else {
                            usersSection(users: viewModel.users)
                        }

                        CacheLogPanel(title: "Cache Feed", logs: viewModel.cacheLogs)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Users Flow")
            .toolbarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search DummyJSON users"
            )
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.scheduleSearch()
            }
            .onChange(of: viewModel.selectedLimit) { _, _ in
                viewModel.applySelectedLimit()
            }
            .refreshable {
                await viewModel.reload()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isPrefetching {
                        Button("Cancel Prefetch") {
                            viewModel.cancelPrefetch()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    private func heroSection(bindableViewModel: Bindable<UsersListViewModel>) -> some View {
        VStack(alignment: .center, spacing: 18) {
            HStack(spacing: 14) {
                statChip(
                    title: "Users",
                    value: "\(viewModel.totalUsers)",
                    tint: Color.accentColor.opacity(0.14),
                    trailingSystemImage: "person.2.fill"
                )

                Menu {
                    Picker("Showing", selection: Binding(
                        get: { bindableViewModel.selectedLimit.wrappedValue },
                        set: { bindableViewModel.selectedLimit.wrappedValue = $0 }
                    )) {
                        ForEach(viewModel.availableLimits, id: \.self) { limit in
                            Text("\(limit)").tag(limit)
                        }
                    }
                } label: {
                    statChip(
                        title: "Showing",
                        value: "\(viewModel.selectedLimit)",
                        tint: Color.orange.opacity(0.16),
                        trailingSystemImage: "chevron.up.chevron.down"
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if viewModel.isPrefetching {
                Label("TaskGroup is prefetching the first profiles in the background.", systemImage: "bolt.horizontal.circle.fill")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color("SurfaceElevated"))
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .strokeBorder(Color("SurfaceStroke"), lineWidth: 1)
                }
        )
        .shadow(color: Color("CardShadow"), radius: colorScheme == .dark ? 18 : 12, y: 10)
    }

    private func usersSection(users: [UserPreview]) -> some View {
        LazyVStack(spacing: 14) {
            ForEach(users) { user in
                NavigationLink {
                    UserDetailView(viewModel: makeDetailViewModel(user.id))
                } label: {
                    UserRowCard(user: user)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var loadingSection: some View {
        UIComponents.LoadingView(rowCount: 4, rowHeight: 110)
            .frame(height: 480)
    }

    private func statChip(
        title: String,
        value: String,
        tint: Color,
        trailingSystemImage: String? = nil
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 36, height: 36)

                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("ChipBackground"))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color("SurfaceStroke"), lineWidth: 1)
                }
        )
    }
}

#Preview {
    let repository = UsersRepository()
    UsersListView(
        viewModel: UsersListViewModel(repository: repository),
        makeDetailViewModel: { UserDetailViewModel(userID: $0, repository: repository) }
    )
}
