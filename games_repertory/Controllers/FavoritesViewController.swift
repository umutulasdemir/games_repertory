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
        getFavorites(isFavList: favoriteGamesList, games: targetgGames)
        LoadGamesData()
    }
    private func LoadGamesData() {
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabbar2 = tabBarController as! BaseUITabBarController?
        favoriteGamesList = tabbar2?.favoriteGamesList
        targetgGames = (tabbar2?.games)!
        getFavorites(isFavList: favoriteGamesList, games: targetgGames)
        loadImages(games: gameViewModel.getGames())
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList = self.favoriteGamesList
    }
    
    func checkTableView(){
        if tableView.visibleCells.isEmpty {
        }
    }
    func getFavorites(isFavList: [Bool]!,games: [Game]!){
        gameViewModel.clearData()
        var p = 0
        for game in games{
            if isFavList[p]{
                gameViewModel.addGame(game: game)
                tableView.reloadData()
            }
            p+=1
        }
        images = Array(repeating: UIImage(named: "loading")!, count: gameViewModel.numberOfRowsInSection(section: 0))
    }
    func loadImages(games: [Game]!){
        var i = 0
        for game in games{
            loadImage(urlS: game.background_image, index: i)
            i+=1
        }
        tableView.reloadData()
    }
    func loadImage(urlS: String!, index: Int){
        guard let posterString = urlS else {return}
        let urlString = posterString
        //print("OHOH", urlString)
        guard let posterImageURL = URL(string: urlString) else {
            self.images![index] = UIImage(named: "loading")!
            return
        }
        getImageDataFrom(url: posterImageURL, index: index)
    }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = gameViewModel.numberOfRowsInSection(section: section)
        
        if count != 0 {
            favoritesTitle.title = "Favorites(\(count))"}
        else {
            favoritesTitle.title = "Favorites"
        }
                if i == 0 {
                    getFavorites(isFavList: favoriteGamesList, games: targetgGames)
                    loadImages(games: gameViewModel.getGames())
                    i=2
                }
                    return max(count,1)
                }

        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : GameCell
        if gameViewModel.getCount() != 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! GameCell
            let game = gameViewModel.cellForRowAt(indexPath: indexPath)
            cell.setCellWithValuesOf(game, image: images![indexPath.row])
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "noCell2", for: indexPath) as! GameCell
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        return cell
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
