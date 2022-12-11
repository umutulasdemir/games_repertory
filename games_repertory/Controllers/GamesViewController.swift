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
    var isKeyBoard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        LoadGamesData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    private func LoadGamesData() {
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        let tabbar = tabBarController as! BaseUITabBarController?
        favoriteGamesList = tabbar?.favoriteGamesList
    }
    override func viewWillDisappear(_ animated: Bool) {
        let tabbar = self.tabBarController as! BaseUITabBarController?
        tabbar?.favoriteGamesList = self.favoriteGamesList
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        gameViewModel.self.clearData()
        images = Array(repeating: UIImage(systemName: "gamecontroller.fill")!, count: targetgGames.count)
        if searchText.count < 4{
            tableView.reloadData()
            return
        }
        var i = 0
        for game in targetgGames{
            guard let name = game.name else{
                return
            }
            if name.lowercased().contains(searchText.lowercased()){
                gameViewModel.addGame(game: game)
                loadImage(urlS: game.background_image, index: i)
                i+=1
            }
        }
        tableView.reloadData()
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
            self.images![index] = UIImage(systemName: "gamecontroller.fill")!
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

extension GamesViewController: UITableViewDataSource,  UITableViewDelegate{
    
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : GameCell
        if gameViewModel.getCount() != 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
            let game = gameViewModel.cellForRowAt(indexPath: indexPath)
            cell.setCellWithValuesOf(game,image: images![indexPath.row])
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "noCell", for: indexPath) as! GameCell
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isKeyBoard {
            self.view.endEditing(true)
            return
        }
        if let vc = storyboard?.instantiateViewController(identifier:
        "DetailGameTableViewController") as?
            DetailGameTableViewController{
            let temp = gameViewModel.getGames()
            var i = 0
            for game in targetgGames{
                if game.id == temp[indexPath.row].id {
                    vc.id = targetgGames[i].id!
                    vc.index = i
                    vc.image = images![i]
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
