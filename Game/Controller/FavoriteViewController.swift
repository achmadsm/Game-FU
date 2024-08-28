//
//  FavoriteViewController.swift
//  Game
//
//  Created by + on 2/22/1446 AH.
//

import UIKit

class FavoriteViewController: UIViewController {
    private var favorites: [FavoriteModel] = []
    private lazy var gameProvider: GameProvider = { GameProvider() }()

    @IBOutlet var favoriteTableView: UITableView!
    @IBOutlet var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false
        loadGames()
    }

    private func loadGames() {
        gameProvider.getAllGame { result in
            DispatchQueue.main.async {
                self.favorites = result
                self.favoriteTableView.reloadData()
                if self.favorites.isEmpty {
                    self.emptyLabel.isHidden = false
                } else {
                    self.emptyLabel.isHidden = true
                }
            }
        }
    }

    private func setupView() {
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self

        favoriteTableView.register(
            UINib(nibName: "GameTableViewCell", bundle: nil),
            forCellReuseIdentifier: "gameTableViewCell"
        )
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableViewCell", for: indexPath) as? GameTableViewCell {
            let favorite = favorites[indexPath.row]
            cell.container.layer.cornerRadius = 8
            cell.container.clipsToBounds = true

            cell.gameName.text = favorite.name
            cell.gameReleased.text = favorite.released
            cell.gameRating.text = String(format: "%.1f", favorite.rating ?? 0)
            cell.gameImage.image = favorite.image
            cell.gameImage.layer.cornerRadius = 16.0
            cell.gameImage.clipsToBounds = true

            if favorite.state == .new {
                cell.indicatorLoading.isHidden = false
                cell.indicatorLoading.startAnimating()
                startDownload(favorite: favorite, indexPath: indexPath)
            } else {
                cell.indicatorLoading.stopAnimating()
                cell.indicatorLoading.isHidden = true
            }

            return cell
        } else {
            return UITableViewCell()
        }
    }

    fileprivate func startDownload(favorite: FavoriteModel, indexPath: IndexPath) {
        let imageDownloader = ImageDownloader()
        if favorite.state == .new {
            Task {
                do {
                    let image = try await imageDownloader.downloadImage(url: favorite.backgroundImage!)
                    favorite.state = .downloaded
                    favorite.image = image
                    self.favoriteTableView.reloadRows(at: [indexPath], with: .automatic)
                } catch {
                    favorite.state = .failed
                    favorite.image = nil
                }
            }
        }
    }
}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedGame = favorites[indexPath.row]
        performSegue(withIdentifier: "favoriteToDetail", sender: selectedGame)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteToDetail" {
            if let detailViewController = segue.destination as? DetailGameViewController,
               let selectedGame = sender as? FavoriteModel {
                detailViewController.gameId = Int(selectedGame.id!)
            }
        }
    }
}
