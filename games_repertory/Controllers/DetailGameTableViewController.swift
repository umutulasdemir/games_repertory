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
    
    // Variables set by data transfer
    var name: String?
    var image: UIImage?
    var index: Int?
    var isFav: Bool?
    var id = 0
    // ------------------------------
    
    // Initialize necessary variables and constants
    private var apiService = ApiService()
    private let apiKey = "3be8af6ebf124ffe81d90f514e59856c"
    private var urlString: String = ""
    private var lastUrl: URL?
    var callBack: ((_ index: Int, _ isFav: Bool)-> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = self.image
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 70
        } else {
            // Fallback on earlier versions
        }
        self.gameName.text = name
        fetchDetailGamesData(id: id){[weak self] in} // Fetch the details via API call
        action()
    }
    
    func action(){
        print("Favorite Check: ", isFav!)
        
        // Determine the button label and action on top right
        if isFav!{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourited", style: .plain, target: self, action: #selector(self.unfavorite(_:)))
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(self.favorite(_:)))
        }
        // ---------------------------------------------------

        // Assign actions to the other two labels
        let redditLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.redditLinkLabelTapped(_:)))
        let webSiteLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.webSiteLinkLabelTapped(_:)))
        self.redditLinkLabel.isUserInteractionEnabled = true
        self.redditLinkLabel.addGestureRecognizer(redditLabelTap)
        self.webSiteLinkLabel.isUserInteractionEnabled = true
        self.webSiteLinkLabel.addGestureRecognizer(webSiteLabelTap)
        // ---------------------------------------------------
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callBack?(index!,isFav ?? false)
    }
    
    // Open swift.com if tapped to the reddit link or the website link
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
    // ---------------------------------------------------------------
    
    // Change the button label and action if clicked
    @objc func favorite(_ sender: UITapGestureRecognizer) {
        print("Favorited!")
        isFav = true
        navigationItem.rightBarButtonItem?.title = "Favourited"
        navigationItem.rightBarButtonItem?.action = #selector(self.unfavorite(_:))
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList![self.index!] = true
        print("Favorite Check: ", isFav!)
    }
    @objc func unfavorite(_ sender: UITapGestureRecognizer) {
        print("Unfavorited!")
        isFav = false
        navigationItem.rightBarButtonItem?.title = "Favourite"
        navigationItem.rightBarButtonItem?.action = #selector(self.favorite(_:))
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList![self.index!] = false
        print("Favorite Check: ", isFav!)
    }
    // ----------------------------------------------
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 // Only one section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4 // Only four rows
    }
    
    // Fetch and assign the game details via API call
    func fetchDetailGamesData(id: Int,completion: @escaping () -> ()){
        let gamesUrl = "https://api.rawg.io/api/games/"+id.description+"?key="+apiKey
        // weak self - prevent retain cycles
        print("Fetching detail games data..")
        apiService.getDetailGamesData(gamesUrl: gamesUrl) { [weak self] (result) in // API Call
            switch result {
            case .success(let listOf): // If successful
                
                // Fill the cell with corresponding data
                self?.detailText.text = listOf.description?.HtmlToString
                guard let posterString = listOf.background_image else {return}
                self?.urlString = posterString
                
                // Try to get the image via API call, fill with placeholder if it fails
                guard let posterImageURL = URL(string: self!.urlString) else {
                    self?.imageView.image = UIImage(systemName: "gamecontroller.fill")
                    return
                }
                self?.getImageDataFrom(url: posterImageURL) // API Call
                // --------------------------------------------------------------------
                
            case .failure(let error):
                // Something is wrong with the JSON file or the model
                print("Error processing json data: \(error)")
            }
        }
    }
    
    // Get the game image via API call and assign it
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
    
// Extend the String object to include a method to convert HTML to string
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
