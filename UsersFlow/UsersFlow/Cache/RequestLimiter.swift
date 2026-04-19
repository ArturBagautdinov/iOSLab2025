//
//  RequestLimiter.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import Foundation

actor RequestLimiter {
    private let maximumConcurrentRequests: Int
    private var activeRequests = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(maximumConcurrentRequests: Int) {
        self.maximumConcurrentRequests = maximumConcurrentRequests
    }

    func acquire() async {
        guard activeRequests >= maximumConcurrentRequests else {
            activeRequests += 1
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func release() {
        if let next = waiters.first {
            waiters.removeFirst()
            next.resume()
            return
        }

        activeRequests = max(0, activeRequests - 1)
    }
}
