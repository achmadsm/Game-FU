//
//  ViewController.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var gameTableView: UITableView!

    private var games: [Game] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        gameTableView.dataSource = self

        gameTableView.register(UINib(nibName: "GameTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "gameTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await getGames() }
    }
    
    func getGames() async {
        let network = NetworkService()
        do {
            games = try await network.getGames()
            gameTableView.reloadData()
        } catch {
            fatalError("Error: connection failed.")
        }
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
            cell.gameRating.text = String(format: "%.2f", game.rating)
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
