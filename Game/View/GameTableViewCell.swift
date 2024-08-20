//
//  GameTableViewCell.swift
//  Game
//
//  Created by + on 2/14/1446 AH.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet var gameImage: UIImageView!
    @IBOutlet var gameName: UILabel!
    @IBOutlet var gameReleased: UILabel!
    @IBOutlet var gameRating: UILabel!
    @IBOutlet var container: UIView!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
