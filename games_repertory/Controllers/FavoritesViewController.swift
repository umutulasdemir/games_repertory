//
//  ViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 29.11.2022.
//

import UIKit

class FavoritesViewController: UIViewController, UITabBarDelegate {
    
   
    @IBOutlet weak var favoritesTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var favoriteGamesList: [Bool]?
    private var gameViewModel = GameViewModel()
    var targetgGames = [Game]()
    var i = 0
    private var images: [UIImage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        //getFavorites(isFavList: favoriteGamesList, games: targetgGames)
        LoadGamesData()
    }
    
    
    private func LoadGamesData() { // Called at the beginning to do an API call and fill targetGames
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
        }
    }
    
    // Pull favoriteGamesList and targetGames from tab bar, change local targetGames to only include favorites
    override func viewWillAppear(_ animated: Bool) {
        let tabbar2 = tabBarController as! BaseUITabBarController?
        favoriteGamesList = tabbar2?.favoriteGamesList
        targetgGames = (tabbar2?.games)!
        getFavorites(isFavList: favoriteGamesList, games: targetgGames)
        loadImages(games: gameViewModel.getGames())

    }
    
    // Pass the most relevant favoriteGamesList to the tab bar
    override func viewWillDisappear(_ animated: Bool) {
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList = self.favoriteGamesList
    }
    
    // Change local targetGames to only include favorites
    func getFavorites(isFavList: [Bool]!,games: [Game]!){
        gameViewModel.clearData()
        var p = 0
        for game in games{
            if isFavList[p]{
                gameViewModel.addGame(game: game)
            }
            p+=1
        }
        tableView.reloadData() // Load the table with current list
    }
    
    // Call loadImage() for each game in given list
    func loadImages(games: [Game]!){
        print("ALO:", games.count)
        var i = 0
        for game in games{
            loadImage(urlS: game.background_image, index: i)
            i+=1
        }
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


extension FavoritesViewController: UITableViewDataSource,  UITableViewDelegate{
    
    // Initialize the table depending on the amount of games in the list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = gameViewModel.numberOfRowsInSection(section: section)
        
        if count != 0 {
            favoritesTitle.title = "Favourites(\(count))"}
        else {
            favoritesTitle.title = "Favourites"
        }
                if i == 0 {
                    images = Array(repeating: UIImage(systemName: "gamecontroller.fill")!, count: gameViewModel.numberOfRowsInSection(section: 0))
                    getFavorites(isFavList: favoriteGamesList, games: targetgGames)
                    loadImages(games: gameViewModel.getGames())
                    i=2
                }
                    return max(count,1)
                }

    // Called for each game in the list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : GameCell // Declare the cell
        if gameViewModel.getCount() != 0{ // If there are games to display
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! GameCell // Initialize cell
            let game = gameViewModel.cellForRowAt(indexPath: indexPath) // Get the game data from the list
            cell.setCellWithValuesOf(game, image: images![indexPath.row]) // Fill in the cell with the game data
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "noCell2", for: indexPath) as! GameCell // Initialize noCell
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none // Remove seperator for a better look
        }
        return cell
    }
    
    // Called when the client swipes a game to the left
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, actionPerformed: @escaping (Bool) -> ()) in
            let alert = UIAlertController(title: "Remove from favorites?", message: "Are you sure you want to remove this game from favorites?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                actionPerformed(false)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alertAction) in
                tableView.beginUpdates()
                let deletedId = self.gameViewModel.getGames()[indexPath.row].id
                self.gameViewModel.removeGame(index: indexPath.row)
                for (i, game) in self.targetgGames.enumerated(){
                        if game.id == deletedId{
                            self.favoriteGamesList![i] = false
                            break
                        }
                    }
                let tabbar = self.tabBarController as! BaseUITabBarController?
                tabbar?.favoriteGamesList = self.favoriteGamesList
                if(self.gameViewModel.getCount() != 0){
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else{ // there should be at least one cell at least to show no favorites found with "nocell".
                    tableView.reloadData()
                }
                tableView.endUpdates()
                actionPerformed(true)
            }))
            self.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier:
        "DetailGameTableViewController") as?
            DetailGameTableViewController{
            let temp = gameViewModel.getGames()
            var i = 0
            for game in targetgGames{
                if game.id == temp[indexPath.row].id {
                    vc.id = targetgGames[i].id!
                    vc.index = i
                    vc.image = images![indexPath.row] // images is limited with current game count.
                    vc.name = targetgGames[i].name
                    vc.isFav = favoriteGamesList?[i]
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

