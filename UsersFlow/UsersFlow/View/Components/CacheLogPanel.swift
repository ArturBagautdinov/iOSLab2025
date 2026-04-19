//
//  CacheLogPanel.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import SwiftUI

struct CacheLogPanel: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let logs: [UsersCache.LogEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(title, systemImage: "internaldrive.fill")
                    .font(.system(.headline, design: .rounded, weight: .bold))

                Spacer()

                Text("actor cache")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color("MutedChipBackground"), in: Capsule())
            }

            if logs.isEmpty {
                Text("No cache events yet. Open a profile or wait for prefetch to finish.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(logs) { log in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.orange.opacity(0.85))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.message)
                                .font(.system(.footnote, design: .rounded, weight: .medium))

                            Text(log.createdAt, style: .time)
                                .font(.system(.caption2, design: .rounded, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color("SurfacePrimary"))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color("SurfaceStroke"), lineWidth: 1)
                }
        )
        .shadow(color: Color("CardShadow"), radius: colorScheme == .dark ? 16 : 10, y: 8)
    }
}
