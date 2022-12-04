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
}

extension GamesViewController: UITableViewDataSource,  UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if i == 0 {
            targetgGames = gameViewModel.getGames()
            i=2
        }
            return max(gameViewModel.numberOfRowsInSection(section: section),1)
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
