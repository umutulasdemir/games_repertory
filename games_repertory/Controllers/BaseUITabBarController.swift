//
//  BaseUITabBarController.swift
//  games_repertory
//
//  Created by Umut Ulaş Demir on 8.12.2022.
//

import UIKit

class BaseUITabBarController: UITabBarController {
    
    var favoriteGamesList: [Bool]?
    var games: [Game]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
