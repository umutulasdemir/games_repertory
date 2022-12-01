//
//  GameViewModel.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//

import Foundation

class GameViewModel {
    
    private var apiService = ApiService()
    private var targetgGames = [Game]()
    
    
    func fetchGamesData(completion: @escaping () -> ()) {
        
        
        let gamesUrl = "https://api.rawg.io/api/games?key=3be8af6ebf124ffe81d90f514e59856c"
        // weak self - prevent retain cycles
        print("Fetching games data..")
        apiService.getGamesData(gamesUrl: gamesUrl) { [weak self] (result) in
            print(result)
            switch result {
            case .success(let listOf):
                self?.targetgGames = listOf.games
                completion()
            case .failure(let error):
                // Something is wrong with the JSON file or the model
                print("Error processing json data: \(error)")
            }
        }
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if targetgGames.count != 0 {
            print("total games count: ",targetgGames.count)
            return targetgGames.count
        }
        return 0
    }
    
    func cellForRowAt (indexPath: IndexPath) -> Game {
        return targetgGames[indexPath.row]
    }
}
