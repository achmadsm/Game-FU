//
//  GameModel.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import UIKit

class Game: Codable {
    let id: Int
    let name, released: String
    let backgroundImage: URL
    let rating: Double
    let genres: [Genre]
    let descriptionRaw: String

    var image: UIImage?
    var state: DownloadState = .new

    enum CodingKeys: String, CodingKey {
        case id, name, released
        case backgroundImage = "background_image"
        case rating
        case genres
        case descriptionRaw = "description_raw"
    }

    init(id: Int, name: String, released: String, backgroundImage: URL, rating: Double, genres: [Genre], descriptionRaw: String) {
        self.id = id
        self.name = name
        self.released = released
        self.backgroundImage = backgroundImage
        self.rating = rating
        self.genres = genres
        self.descriptionRaw = descriptionRaw
    }
}

class Genre: Codable {
    let id: Int
    let name: String
    let gamesCount: Int
    let imageBackground: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case gamesCount = "games_count"
        case imageBackground = "image_background"
    }

    init(id: Int, name: String, gamesCount: Int, imageBackground: String) {
        self.id = id
        self.name = name
        self.gamesCount = gamesCount
        self.imageBackground = imageBackground
    }
}

struct GameResponses: Codable {
    let status: String
    let games: [GameResponse]

    enum CodingKeys: String, CodingKey {
        case status
        case games = "results"
    }
}

struct GameResponse: Codable {
    let id: Int
    let name, released: String
    let backgroundImage: URL
    let rating: Double
    let genres: [Genre]
    let descriptionRaw: String

    enum CodingKeys: String, CodingKey {
        case id, name, released
        case backgroundImage = "background_image"
        case rating
        case genres
        case descriptionRaw = "description_raw"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        released = try container.decode(String.self, forKey: .released)
        backgroundImage = URL(string: try container.decode(String.self, forKey: .backgroundImage))!
        rating = try container.decode(Double.self, forKey: .rating)
        genres = try container.decode([Genre].self, forKey: .genres)
        descriptionRaw = try container.decode(String.self, forKey: .descriptionRaw)
    }
}
