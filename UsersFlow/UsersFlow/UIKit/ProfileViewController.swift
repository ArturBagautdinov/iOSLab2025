//
//  ProfileViewController.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    struct ViewData: Equatable {
        let fullName: String
        let email: String
        let imageURL: URL?
        let isFollowing: Bool
    }

    var onFollowTap: (() -> Void)?

    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let followButton = UIButton(type: .system)

    private var imageTask: URLSessionDataTask?
    private var currentImageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
    }

    deinit {
        imageTask?.cancel()
    }

    func configure(with viewData: ViewData) {
        nameLabel.text = viewData.fullName
        emailLabel.text = viewData.email

        let buttonTitle = viewData.isFollowing ? "Following" : "Follow"
        var configuration = followButton.configuration ?? .filled()
        configuration.title = buttonTitle
        configuration.baseBackgroundColor = viewData.isFollowing ? .systemGreen : .systemBlue
        followButton.configuration = configuration

        loadImage(from: viewData.imageURL)
    }

    private func setupView() {
        view.backgroundColor = .clear

        cardView.backgroundColor = UIColor(named: "SurfacePrimary") ?? .secondarySystemBackground
        cardView.layer.cornerRadius = 28
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = (UIColor(named: "CardShadow") ?? UIColor.black).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 22
        cardView.layer.shadowOffset = CGSize(width: 0, height: 12)
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = (UIColor(named: "SurfaceStroke") ?? UIColor.white.withAlphaComponent(0.2)).cgColor

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 52
        avatarImageView.backgroundColor = .tertiarySystemFill
        avatarImageView.tintColor = .secondaryLabel
        avatarImageView.image = UIImage(systemName: "person.fill")

        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        emailLabel.font = .systemFont(ofSize: 17, weight: .medium)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        emailLabel.numberOfLines = 2

        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .bold)
            return outgoing
        }
        followButton.configuration = configuration
        followButton.layer.cornerRadius = 16
        followButton.layer.cornerCurve = .continuous
        followButton.addTarget(self, action: #selector(handleFollowTap), for: .touchUpInside)
    }

    private func setupHierarchy() {
        view.addSubview(cardView)

        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(emailLabel)
        cardView.addSubview(followButton)
    }

    private func setupLayout() {
        [cardView, avatarImageView, nameLabel, emailLabel, followButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            avatarImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 104),
            avatarImageView.heightAnchor.constraint(equalToConstant: 104),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            followButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 22),
            followButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            followButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28),
            followButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
    }

    private func loadImage(from url: URL?) {
        imageTask?.cancel()
        currentImageURL = url

        guard let url else {
            avatarImageView.image = UIImage(systemName: "person.fill")
            return
        }

        avatarImageView.image = UIImage(systemName: "person.fill")

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let self,
                self.currentImageURL == url,
                let data,
                let image = UIImage(data: data)
            else {
                return
            }

            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }

        imageTask?.resume()
    }

    @objc
    private func handleFollowTap() {
        onFollowTap?()
    }
}
