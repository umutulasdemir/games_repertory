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
    func setCellWithValuesOf(_ game:Game) {
        updateUI(name: game.name, mcScore: game.metacritic, categories: game.genres, imageView: game.background_image)
    }
    
    // Update the UI Views
    private func updateUI(name: String?, mcScore: Int?, categories: [Genre]?, imageView: String?) {
        self.gameName.text = name
        self.mcScore.text = mcScore?.description
        self.categories.text = combineGenres(genres: categories)
        
        guard let posterString = imageView else {return}
        urlString = posterString
        
        guard let posterImageURL = URL(string: urlString) else {
            self.gameImageView.image = UIImage(named: "noImageAvailable")
            return
        }
        
        // Before we download the image we clear out the old one
        self.gameImageView.image = nil
        
        getImageDataFrom(url: posterImageURL)
        
    }
    
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
    
    // MARK: - Get image data
    private func getImageDataFrom(url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Handle Error
            if let error = error {
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                // Handle Empty Data
                print("Empty Data")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.gameImageView.image = image
                }
            }
        }.resume()
    }
}
