//
//  ViewController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 29.11.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var gameViewModel = GameViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadGamesData()
        // Do any additional setup after loading the view.
    }
    private func LoadGamesData() {
        
        gameViewModel.fetchGamesData{ [weak self] in
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
            }
        }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return gameViewModel.numberOfRowsInSection(section: section)
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
        
        let game = gameViewModel.cellForRowAt(indexPath: indexPath)
        cell.setCellWithValuesOf(game)
        return cell
    }
}

