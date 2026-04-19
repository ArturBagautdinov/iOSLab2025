//
//  UserRowCard.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import SwiftUI

struct UserRowCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let user: UserPreview

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: user.image) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    LinearGradient(
                        colors: [.orange.opacity(0.9), .pink.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 68, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(user.fullName)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(user.primarySubtitle)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(user.secondarySubtitle)
                    .font(.system(.footnote, design: .rounded, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color("SurfacePrimary"))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color("SurfaceStroke"), lineWidth: 1)
                }
        )
        .shadow(color: Color("CardShadow"), radius: colorScheme == .dark ? 16 : 10, y: 8)
    }
}
