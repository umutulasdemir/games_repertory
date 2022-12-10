//
//  Model.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 30.11.2022.
//
import Foundation

struct GamesData: Decodable {
    let games: [Game]
    
    private enum CodingKeys: String, CodingKey {
        case games = "results"
    }
}

struct Genre: Decodable {
    
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
}
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

struct DetailGame: Decodable {
    let description: String?
    let background_image: String?
    
    private enum CodingKeys: String, CodingKey {
        case description
        case background_image
    }
}
