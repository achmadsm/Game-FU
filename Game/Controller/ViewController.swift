//
//  ViewController.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import UIKit

class ViewController: UIViewController {
    private var games: [Game] = []

    @IBOutlet var gameTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false

        Task { await getGames() }
    }

    func getGames() async {
        let network = NetworkService()
        do {
            games = try await network.getGames()
            gameTableView.reloadData()
        } catch {
            showAlert(message: "Failed to load games detail. Please try again.")
        }
    }
    
    private func setupView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self

        gameTableView.register(
            UINib(nibName: "GameTableViewCell", bundle: nil),
            forCellReuseIdentifier: "gameTableViewCell"
        )
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return games.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "gameTableViewCell",
            for: indexPath
        ) as? GameTableViewCell {
            let game = games[indexPath.row]
            cell.container.layer.cornerRadius = 8
            cell.container.clipsToBounds = true

            cell.gameName.text = game.name
            cell.gameReleased.text = game.released
            cell.gameRating.text = String(format: "%.1f", game.rating)
            cell.gameImage.image = game.image
            cell.gameImage.layer.cornerRadius = 16.0
            cell.gameImage.clipsToBounds = true

            if game.state == .new {
                cell.indicatorLoading.isHidden = false
                cell.indicatorLoading.startAnimating()
                startDownload(game: game, indexPath: indexPath)
            } else {
                cell.indicatorLoading.stopAnimating()
                cell.indicatorLoading.isHidden = true
            }

            return cell
        } else {
            return UITableViewCell()
        }
    }

    fileprivate func startDownload(game: Game, indexPath: IndexPath) {
        let imageDownloader = ImageDownloader()
        if game.state == .new {
            Task {
                do {
                    let image = try await imageDownloader.downloadImage(url: game.backgroundImage)
                    game.state = .downloaded
                    game.image = image
                    self.gameTableView.reloadRows(at: [indexPath], with: .automatic)
                } catch {
                    game.state = .failed
                    game.image = nil
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedGame = games[indexPath.row]
        performSegue(withIdentifier: "moveToDetail", sender: selectedGame)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToDetail" {
            if let detailViewController = segue.destination as? DetailGameViewController,
               let selectedGame = sender as? Game {
                detailViewController.gameId = selectedGame.id
            }
        }
    }
}
