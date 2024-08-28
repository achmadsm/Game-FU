//
//  DetailGameViewController.swift
//  Game
//
//  Created by + on 2/15/1446 AH.
//

import UIKit

class DetailGameViewController: UIViewController {
    @IBOutlet var gameImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var releasedLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var favoriteButton: UIBarButtonItem!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!

    var gameId: Int?
    private var isFavorite = false
    private lazy var gameProvider: GameProvider = { GameProvider() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        isGameFavorited()
        updateFavoriteButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        if let id = gameId {
            Task { await fetchGame(id: id) }
        }
    }

    private func setupUI() {
        nameLabel.text = "..."
        genreLabel.text = "..."
        ratingLabel.text = "..."
        releasedLabel.text = "..."
        descLabel.text = "..."
    }

    func fetchGame(id: Int) async {
        let network = NetworkService()
        do {
            let fetchedGame = try await network.getGame(id: id)
            updateUI(with: fetchedGame)
        } catch {
            showAlert(message: "Failed to load game detail. Please try again.")
        }
    }

    func updateUI(with game: Game) {
        nameLabel.text = game.name
        ratingLabel.text = String(format: "%.1f", game.rating)
        genreLabel.text = game.genres.map { $0.name }.joined(separator: ", ")
        releasedLabel.text = game.released
        descLabel.text = game.descriptionRaw.isEmpty ? "No description available." : game.descriptionRaw
        gameImage.image = game.image

        if game.state == .new {
            indicatorLoading.isHidden = false
            indicatorLoading.startAnimating()
            startDownload(game: game)
        } else {
            indicatorLoading.stopAnimating()
            indicatorLoading.isHidden = true
        }
    }

    fileprivate func startDownload(game: Game) {
        let imageDownloader = ImageDownloader()
        if game.state == .new {
            Task {
                do {
                    let image = try await imageDownloader.downloadImage(url: game.backgroundImage)
                    game.state = .downloaded
                    game.image = image
                    self.updateUI(with: game)
                } catch {
                    game.state = .failed
                    game.image = nil
                }
            }
        }
    }

    private func isGameFavorited() {
        guard let id = gameId else { return }
        gameProvider.isGameFavorite(id) { result in
            self.isFavorite = result
            DispatchQueue.main.async { self.updateFavoriteButton() }
        }
    }

    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        Task { @MainActor in
            guard let id = gameId else { return }

            if isFavorite {
                gameProvider.deleteFavorite(id) { [weak self] in
                    DispatchQueue.main.async {
                        self?.isFavorite = false
                        self?.updateFavoriteButton()
                    }
                }
            } else {
                let network = NetworkService()
                let game = try await network.getGame(id: id)

                gameProvider.createFavorite(
                    id,
                    game.name,
                    game.released,
                    game.backgroundImage,
                    game.rating,
                    game.genres.map { $0.name }.joined(separator: ", "),
                    game.descriptionRaw
                ) { [weak self] in
                    DispatchQueue.main.async {
                        self?.isFavorite = true
                        self?.updateFavoriteButton()
                    }
                }
            }
        }
    }

    private func updateFavoriteButton() {
        let symbolName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.image = UIImage(systemName: symbolName)
    }
}
