//
//  NetworkService.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case badURL
    case decodingError
    case networkError(Error)
}

class NetworkService {
    private let baseURL = "https://rawg-mirror.vercel.app/api/games"

    func getGames() async throws -> [Game] {
        guard let components = URLComponents(string: baseURL) else {
            throw NetworkError.badURL
        }
        let request = URLRequest(url: components.url!)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw NetworkError.badResponse
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(GameResponses.self, from: data)

            return gamesMapper(input: result.games)
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    func getGame(id: Int) async throws -> Game {
        guard let components = URLComponents(string: "\(baseURL)/\(id)") else {
            throw NetworkError.badURL
        }
        
        let request = URLRequest(url: components.url!)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw NetworkError.badResponse
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(GameResponse.self, from: data)

            return gameMapper(input: result)
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}

extension NetworkService {
    fileprivate func gamesMapper(input gameResponses: [GameResponse]) -> [Game] {
        return gameResponses.map { result in
            Game(
                id: result.id,
                name: result.name,
                released: result.released,
                backgroundImage: result.backgroundImage,
                rating: result.rating,
                genres: result.genres,
                descriptionRaw: result.descriptionRaw
            )
        }
    }

    fileprivate func gameMapper(input gameResponse: GameResponse) -> Game {
        return Game(
            id: gameResponse.id,
            name: gameResponse.name,
            released: gameResponse.released,
            backgroundImage: gameResponse.backgroundImage,
            rating: gameResponse.rating,
            genres: gameResponse.genres,
            descriptionRaw: gameResponse.descriptionRaw
        )
    }
}

