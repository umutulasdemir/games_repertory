//
//  DetailGameViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 5.12.2022.
//

import UIKit

class DetailGameViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailText: UILabel!
    private var gameViewModel = GameViewModel()
    private var detailGame: DetailGame?
    var id = 0
    private var apiService = ApiService()
    private let apiKey = "3be8af6ebf124ffe81d90f514e59856c"
    private var urlString: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDetailGamesData(id: id){[weak self] in}
        // Do any additional setup after loading the view.
    }
    
    func fetchDetailGamesData(id: Int,completion: @escaping () -> ()){
        var gamesUrl = "https://api.rawg.io/api/games/"+id.description+"?key="+apiKey
        // weak self - prevent retain cycles
        print("Fetching detail games data..")
        apiService.getDetailGamesData(gamesUrl: gamesUrl) { [weak self] (result) in
            switch result {
            case .success(let listOf):
                self?.detailText.text = listOf.description?.HtmlToString
                guard let posterString = listOf.background_image else {return}
                self?.urlString = posterString
                guard let posterImageURL = URL(string: self!.urlString) else {
                    self?.imageView.image = UIImage(named: "noImageAvailable")
                    return
                }
                self?.getImageDataFrom(url: posterImageURL)
            case .failure(let error):
                // Something is wrong with the JSON file or the model
                print("Error processing json data: \(error)")
            }
        }
    }
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
                    self.imageView.image = image
                    self.reloadInputViews()
                }
            }
        }.resume()
    }

}
extension String {
    var HtmlToString: String? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString (data: data, options: [.documentType:
                                                                    NSAttributedString.DocumentType.html,. characterEncoding:
                                                                    String.Encoding.utf8.rawValue], documentAttributes: nil).string
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
}
