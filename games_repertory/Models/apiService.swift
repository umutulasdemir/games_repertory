//
//  apiService.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//

import Foundation

class ApiService {
    
    private var dataTask: URLSessionDataTask?
    
    // Get the games with an API call and return it as a decoded object (See 'Model.Gamesdata')
    func getGamesData(gamesUrl: String,completion: @escaping (Result<GamesData, Error>) -> Void) {
        
        //let gamesUrl = "https://api.rawg.io/api/games?key=3be8af6ebf124ffe81d90f514e59856c"
        
        guard let url = URL(string: gamesUrl) else {return}
        
        // Create URL Session - work on the background
        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Handle Error
            if let error = error {
                completion(.failure(error))
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                // Handle Empty Response
                print("Empty Response")
                return
            }
            print("Response status code: \(response.statusCode)")
            
            guard let data = data else {
                // Handle Empty Data
                print("Empty Data")
                return
            }
            
            do {
                // Parse the data
                let decoder = JSONDecoder()
                
                let jsonData = try decoder.decode(GamesData.self, from: data)
                
                // Back to the main thread
                DispatchQueue.main.async {
                    completion(.success(jsonData))
                }
            } catch let error {
                completion(.failure(error))
            }
            
        }
        dataTask?.resume()
    }
    
    // Get game details and return the result as a decoded object (See 'Model.DetailGame')
    func getDetailGamesData(gamesUrl: String,completion: @escaping (Result<DetailGame, Error>) -> Void) {
        
        //let gamesUrl = "https://api.rawg.io/api/games?key=3be8af6ebf124ffe81d90f514e59856c"
        
        guard let url = URL(string: gamesUrl) else {return}
        
        // Create URL Session - work on the background
        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Handle Error
            if let error = error {
                completion(.failure(error))
                print("DataTask error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                // Handle Empty Response
                print("Empty Response")
                return
            }
            print("Response status code: \(response.statusCode)")
            
            guard let data = data else {
                // Handle Empty Data
                print("Empty Data")
                return
            }
            
            do {
                // Parse the data
                let decoder = JSONDecoder()
                
                let jsonData = try decoder.decode(DetailGame.self, from: data)
                
                // Back to the main thread
                DispatchQueue.main.async {
                    completion(.success(jsonData))
                }
            } catch let error {
                completion(.failure(error))
            }
            
        }
        dataTask?.resume()
    }
    
    
}
