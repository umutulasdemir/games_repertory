//
//  ViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 29.11.2022.
//

import UIKit

class FavoritesViewController: UIViewController,UISearchBarDelegate {
    
   
    @IBOutlet weak var favoritesTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var favoriteGamesList: [Bool]?
    private var gameViewModel = GameViewModel()
    var targetgGames = [Game]()
    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        getFavorites(isFavList: favoriteGamesList, games: targetgGames)
        //let tabbar = tabBarController as! BaseUITabBarController?
        //favoriteGamesList = tabbar?.favoriteGamesList
        LoadGamesData()
        // Do any additional setup after loading the view.
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
        tableView.reloadData()
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
            }
            p+=1
        }
        tableView.reloadData()
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
                    //targetgGames = gameViewModel.getGames()
                    getFavorites(isFavList: favoriteGamesList, games: targetgGames)
                    i=2
                }
                    return max(count,1)
                }

        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : GameCell
        if gameViewModel.getCount() != 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
            let game = gameViewModel.cellForRowAt(indexPath: indexPath)
            cell.setCellWithValuesOf(game)
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "noCell", for: indexPath) as! GameCell
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        return cell
    }
}
