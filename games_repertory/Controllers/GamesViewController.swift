//
//  ViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 29.11.2022.
//

import UIKit

class GamesViewController: UIViewController,UISearchBarDelegate, UITabBarDelegate {
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!
    var favoriteGamesList: [Bool]?
    private var gameViewModel = GameViewModel()
    private var targetgGames = [Game]()
    private var images: [UIImage]?
    var i = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        LoadGamesData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    private func LoadGamesData() { // Called at the beginning to do an API call and fill targetGames
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
        }
    }
    
    // Pass favoriteGamesList to the tab bar to keep it updated between windows
    override func viewWillAppear(_ animated: Bool) {
        let tabbar = tabBarController as! BaseUITabBarController?
        favoriteGamesList = tabbar?.favoriteGamesList
    }
    
    // Pass favoriteGamesList to the tab bar to keep it updated between windows
    override func viewWillDisappear(_ animated: Bool) {
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList = self.favoriteGamesList
    }
    
    // For each change in the search bar:
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        gameViewModel.self.clearData() // Clear the game list
        images = Array(repeating: UIImage(systemName: "gamecontroller.fill")!, count: targetgGames.count) // Fill placeholder images
        if searchText.count < 4{ // If less than 4 characters
            tableView.reloadData() // Load the table with current list, meaning an empty list
            return
        } // Else
        
        var i = 0
        for game in targetgGames{
            guard let name = game.name else{
                return
            }
            if name.lowercased().contains(searchText.lowercased()){ // If name includes the searched text
                gameViewModel.addGame(game: game) // Add the game to the list
                loadImage(urlS: game.background_image, index: i) // Load the image of the game to the image list
                i+=1
            }
        }
        tableView.reloadData() // Load the table with current list
    }

    // Call loadImage() for each game in given list
    func loadImages(games: [Game]!){
        var i = 0
        for game in games{
            loadImage(urlS: game.background_image, index: i)
            i+=1
        }
        tableView.reloadData() // Load the table with current list
    }
    
    // If the given string can be converted to a URL, call getImageDataFrom() to do an API call. Else, fill with placeholder.
    func loadImage(urlS: String!, index: Int){
        guard let posterString = urlS else {return}
        let urlString = posterString
        guard let posterImageURL = URL(string: urlString) else {
            self.images![index] = UIImage(systemName: "gamecontroller.fill")!
            return
        }
        getImageDataFrom(url: posterImageURL, index: index)
    }
    
    // Get the game image via an API call and put it into the given index of the image list
    private func getImageDataFrom(url: URL, index: Int) {
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
                    self.images?[index] = image
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }
}

// Extend the class to seperate tableView() functions from others for neater code
extension GamesViewController: UITableViewDataSource,  UITableViewDelegate{
    
    // Initialize the table depending on the amount of games in the list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = gameViewModel.numberOfRowsInSection(section: section)
                if i == 0 {
                    targetgGames = gameViewModel.getGames()
                    images = Array(repeating: UIImage(systemName: "gamecontroller.fill")!, count: count)
                    loadImages(games: targetgGames)
                    favoriteGamesList = Array(repeating: false, count: count)
                    i=2
                    let tabbar = self.tabBarController as! BaseUITabBarController?
                    tabbar?.games = self.targetgGames
                }
                    return max(count,1)
                }

    // Called for each game in the list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : GameCell // Declare the cell
        if gameViewModel.getCount() != 0{ // If there are games to display
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell // Initialize cell
            let game = gameViewModel.cellForRowAt(indexPath: indexPath) // Get the game data from the list
            cell.setCellWithValuesOf(game,image: images![indexPath.row]) // Fill in the cell with the game data
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        else { // If there are no games to display
            cell = tableView.dequeueReusableCell(withIdentifier: "noCell", for: indexPath) as! GameCell // Initialize noCell
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none // Remove seperator for a better look
        }
        return cell
    }
    
    // Called when the client clicks a game in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier:
        "DetailGameTableViewController") as?
            DetailGameTableViewController{ // Set the view controller to pass to
            let temp = gameViewModel.getGames() // Get the games in the current table
            var i = 0
            for game in targetgGames{
                if game.id == temp[indexPath.row].id { // When the clicked game is found
                    
                    // Data transfer
                    vc.id = targetgGames[i].id!
                    vc.index = i
                    vc.image = images![i]
                    vc.name = targetgGames[i].name
                    vc.isFav = favoriteGamesList?[i]
                    // -----------------------------
                    
                    // Update favoriteGamesList when returning to the games screen
                    vc.callBack = { (index: Int,isFav: Bool) in
                        self.favoriteGamesList?[index] = isFav
                        let tabbar = self.tabBarController as! BaseUITabBarController?
                        tabbar?.favoriteGamesList = self.favoriteGamesList
                   }
                    break
                }
                i+=1
            }
            self.navigationController?.pushViewController(vc,animated:true)
        }
    }
}
