//
//  UserDetailsViewController.swift
//  UsersFlow
//
//  Created by Artur Bagautdinov on 19.04.2026.
//

import UIKit

final class UserDetailsViewController: UIViewController {
    struct ViewData: Equatable {
        struct Row: Equatable {
            let title: String
            let value: String
        }

        let rows: [Row]
    }

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
    }

    func configure(with viewData: ViewData) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for row in viewData.rows {
            stackView.addArrangedSubview(makeRowView(title: row.title, value: row.value))
        }
    }

    private func setupView() {
        view.backgroundColor = .clear

        cardView.backgroundColor = UIColor(named: "SurfacePrimary")
        cardView.layer.cornerRadius = 28
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = (UIColor(named: "CardShadow") ?? UIColor.black).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 18
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = (UIColor(named: "SurfaceStroke") ?? UIColor.white.withAlphaComponent(0.2)).cgColor

        titleLabel.text = "Profile Snapshot"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    private func setupHierarchy() {
        view.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(stackView)
    }

    private func setupLayout() {
        [cardView, titleLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22)
        ])
    }

    private func makeRowView(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.tertiarySystemFill.withAlphaComponent(0.1)
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.uppercased()
        titleLabel.numberOfLines = 1

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        [titleLabel, valueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        return container
    }
}
