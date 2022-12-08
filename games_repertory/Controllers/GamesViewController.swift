//
//  ViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 29.11.2022.
//

import UIKit

class GamesViewController: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!
    var favoriteGamesList: [Bool]?
    private var gameViewModel = GameViewModel()
    private var targetgGames = [Game]()
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        LoadGamesData()
        // Do any additional setup after loading the view.
    }
    private func LoadGamesData() {
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //tableView.backgroundView = noGameView
        gameViewModel.self.clearData()
        if searchText.count < 4{
            tableView.reloadData()
            return
        }
        for fruit in targetgGames{
            guard let name = fruit.name else{
                return
            }
            if name.lowercased().contains(searchText.lowercased()){
                gameViewModel.addGame(game: fruit)
            }
        }
        tableView.reloadData()
    }
    func checkTableView(){
        if tableView.visibleCells.isEmpty {
            
        }
    }
    /*@IBAction func pushToSecond(_ sender: Any) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailGameTableViewControler")as? DetailGameTableViewController {
             
                //callBack block will execute when user back from SecondViewController.
                 vc.callBack = { (index: Int,isFav: Bool) in
                     self.favoriteGamesList?[index] = isFav
                     print("Favorite Check.. ", index.description + ": " + isFav.description)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }*/
}

extension GamesViewController: UITableViewDataSource,  UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = gameViewModel.numberOfRowsInSection(section: section)
                if i == 0 {
                    targetgGames = gameViewModel.getGames()
                    favoriteGamesList = Array(repeating: false, count: count)
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
                    vc.isFav = favoriteGamesList?[i]
                    vc.callBack = { (index: Int,isFav: Bool) in
                        self.favoriteGamesList?[index] = isFav
                        print("Favorite Check.. ", index.description + ": " + isFav.description)
                   }
                    break
                }
                i+=1
            }
            self.navigationController?.pushViewController(vc,animated:true)
        }
    }
}
