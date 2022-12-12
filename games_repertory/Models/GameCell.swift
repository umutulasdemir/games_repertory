//
//  GameCell.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//

import UIKit

class GameCell: UITableViewCell {
    
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var mcScore: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    
    
    private var urlString: String = ""
    
    // Setup movies values
    func setCellWithValuesOf(_ game:Game, image: UIImage) {
        updateUI(name: game.name, mcScore: game.metacritic, categories: game.genres, imageView: image)
    }
    
    // Update the UI Views
    private func updateUI(name: String?, mcScore: Int?, categories: [Genre]?, imageView: UIImage) {
        self.gameName.text = name
        self.mcScore.text = mcScore?.description
        self.categories.text = combineGenres(genres: categories)
        self.gameImageView.image = imageView
    }
    
    // Format the genres list into one displayable string and return it
    private func combineGenres(genres: [Genre]!)-> String{
        var combinedGenres = ""
        var i = 0
        for genre in genres{
            if i>0{
                combinedGenres = combinedGenres + "," + genre.name!
            }
            else {
                combinedGenres = genre.name!
            }
            i+=1
        }
        return combinedGenres
    }
}
