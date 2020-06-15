//
//  ViewController.swift
//  toVisitPlaces_Avani_C0772788
//
//  Created by Avani Patel on 6/14/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblFavPlaces: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tblFavPlaces.dataSource = self
        tblFavPlaces.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favPlaceCell") as! FavPlacesTableViewCell
        return cell
    }
    
}



