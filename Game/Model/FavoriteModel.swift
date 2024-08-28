//
//  FavoriteModel.swift
//  Game
//
//  Created by + on 2/21/1446 AH.
//

import UIKit

class FavoriteModel {
    var id: Int16?
    var name: String?
    var released: String?
    var backgroundImage: URL?
    var rating: Double?
    var genres: String?
    var descriptionRaw: String?

    var image: UIImage?
    var state: DownloadState = .new

    init(id: Int16? = nil, name: String? = nil, released: String? = nil, backgroundImage: URL? = nil, rating: Double? = nil, genres: String? = nil, descriptionRaw: String? = nil) {
        self.id = id
        self.name = name
        self.released = released
        self.backgroundImage = backgroundImage
        self.rating = rating
        self.genres = genres
        self.descriptionRaw = descriptionRaw
    }
}
