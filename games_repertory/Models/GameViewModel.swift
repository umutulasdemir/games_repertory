//
//  GameViewModel.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//

import Foundation
import UIKit

// The view model for the list of games pulled from the API
class GameViewModel {
    
    private var Images: [UIImage]? // The list of images corresponding to each game
    private var isImagesLoaded: [Bool]?
    private var apiService = ApiService()
    private var targetgGames = [Game]() // The list of games
    private let apiKey = "3be8af6ebf124ffe81d90f514e59856c"
    
    // The API call to get the games
    func fetchGamesData(completion: @escaping () -> ()) {
        
        let gamesUrl = "https://api.rawg.io/api/games?key="+apiKey
        // weak self - prevent retain cycles
        print("Fetching games data..")
        apiService.getGamesData(gamesUrl: gamesUrl) { [weak self] (result) in
            print(result)
            switch result {
            case .success(let listOf):
                self?.targetgGames = listOf.games
                self?.Images = Array(repeating: UIImage(named: "background")!, count: listOf.games.count)
                //self?.isImagesLoaded = Array(repeating: false, count: listOf.games.count)
                //self?.loadImages(games: listOf.games)
                completion()
            case .failure(let error):
                // Something is wrong with the JSON file or the model
                print("Error processing json data: \(error)")
            }
        }
    }
    
    func removeGame(index: Int?){
        targetgGames.remove(at: index!)
    }
    
    // Clear targetGames
    func clearData(){
        targetgGames.removeAll()
    }
    
    func addGame(game: Game){
        targetgGames.append(game)
    }
    
    func getGames()->[Game]{
        return targetgGames
    }
    
    func getCount()->Int{
        return targetgGames.count
    }
    
    
    // Return the number of games in targetGames
    func numberOfRowsInSection(section: Int) -> Int {
        if targetgGames.count != 0 {
            print("total games count: ",targetgGames.count)
            return targetgGames.count
        }
        return 0
    }
    
    // Return the game at index 'indexPath' of targetGames
    func cellForRowAt (indexPath: IndexPath) -> Game {
        return targetgGames[indexPath.row]
    }
}
