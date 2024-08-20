//
//  NetworkService.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import Foundation

class NetworkService {

    func getGames() async throws -> [Game] {
        let componenets = URLComponents(string: "https://rawg-mirror.vercel.app/api/games")!
        let request = URLRequest(url: componenets.url!)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error: Can't fetching data.")
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(GameResponses.self, from: data)

        return gameMapper(input: result.games)
    }
}

extension NetworkService {
    fileprivate func gameMapper(input gameResponses: [GameResponse]) -> [Game] {
        return gameResponses.map { result in
            Game(id: result.id, name: result.name, released: result.released, backgroundImage: result.backgroundImage, rating: result.rating, genres: result.genres, descriptionRaw: result.descriptionRaw)
        }
    }
}
