//
//  Model.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//
import Foundation

// Model for targetGames which is a list of games
struct GamesData: Decodable {
    let games: [Game]
    
    private enum CodingKeys: String, CodingKey {
        case games = "results"
    }
}

// Genre of game
struct Genre: Decodable {
    
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
}

// Each 'Game' inside of 'GamesData'
struct Game: Decodable {
    
    let id: Int?
    let name: String?
    let metacritic: Int?
    let genres: [Genre]?
    let background_image: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case metacritic
        case genres
        case background_image
    }
}

// Game details independent of 'GamesData'. This need a different API call.
struct DetailGame: Decodable {
    let description: String?
    let background_image: String? // URL for API call to get UIImage object
    
    private enum CodingKeys: String, CodingKey {
        case description
        case background_image
    }
}
