//
//  DetailGameTableViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 6.12.2022.
//

import UIKit


class DetailGameTableViewController: UITableViewController {
    
    
    @IBOutlet weak var redditLinkLabel: UILabel!
    @IBOutlet weak var webSiteLinkLabel: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var name: String?
    var index: Int?
    private var gameViewModel = GameViewModel()
    private var detailGame: DetailGame?
    var id = 0
    var i = 0
    private var apiService = ApiService()
    private let apiKey = "3be8af6ebf124ffe81d90f514e59856c"
    private var urlString: String = ""
    private var lastUrl: URL?
    var callBack: ((_ index: Int, _ isFav: Bool)-> Void)?
    var isFav: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.gameName.text = name
        fetchDetailGamesData(id: id){[weak self] in}
        action()

    }
    func action(){
        print("Favorite Check: ", isFav)
        if isFav!{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorited", style: .plain, target: self, action: #selector(self.unfavorite(_:)))
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(self.favorite(_:)))
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back(_:)))
        let favoriteTap = UITapGestureRecognizer(target: self, action: #selector(self.favorite(_:)))
        let unfavoriteTap = UITapGestureRecognizer(target: self, action: #selector(self.unfavorite(_:)))
        let redditLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.redditLinkLabelTapped(_:)))
        let webSiteLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.webSiteLinkLabelTapped(_:)))
        self.redditLinkLabel.isUserInteractionEnabled = true
        self.redditLinkLabel.addGestureRecognizer(redditLabelTap)
        self.webSiteLinkLabel.isUserInteractionEnabled = true
        self.webSiteLinkLabel.addGestureRecognizer(webSiteLabelTap)
    }
    
    @objc func back(_ sender: UITapGestureRecognizer) {
        print("Favorite Check: Back Button Tapped!")
        /*if let vc = storyboard?.instantiateViewController(identifier:
                                                            "GamesViewController") as?
            GamesViewController{
            //vc.favoriteGamesList = favoriteList!
            //self.dismiss(animated: true, completion: {
              //              self.navigationController?.popToRootViewController(animated: true)
                //        })
            self.navigationController?.pushViewController(vc,animated:true)
        }*/
        callBack?(index!,isFav ?? false)
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func redditLinkLabelTapped(_ sender: UITapGestureRecognizer) {
        print("Reddit Link Tapped!")
        guard let url = URL(string: "https://www.swift.org") else { return }
        UIApplication.shared.open(url)
    }
    @objc func webSiteLinkLabelTapped(_ sender: UITapGestureRecognizer) {
        print("Web Site Link Tapped!")
        guard let url = URL(string: "https://www.swift.org") else { return }
        UIApplication.shared.open(url)
    }
    @objc func favorite(_ sender: UITapGestureRecognizer) {
        print("Favorited!")
        isFav = true
        navigationItem.rightBarButtonItem?.title = "Favorited"
        navigationItem.rightBarButtonItem?.action = #selector(self.unfavorite(_:))
        print("Favorite Check: ", isFav)
    }
    @objc func unfavorite(_ sender: UITapGestureRecognizer) {
        print("Unfavorited!")
        isFav = false
        navigationItem.rightBarButtonItem?.title = "Favorite"
        navigationItem.rightBarButtonItem?.action = #selector(self.favorite(_:))
        print("Favorite Check: ", isFav)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    func fetchDetailGamesData(id: Int,completion: @escaping () -> ()){
        let gamesUrl = "https://api.rawg.io/api/games/"+id.description+"?key="+apiKey
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
    func getImageDataFrom(url: URL) {
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
            NSAttributedString.DocumentType.html,
            . characterEncoding:
            String.Encoding.utf8.rawValue],
            documentAttributes: nil).string
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
}
