//
//  ViewController.swift
//  toVisitPlaces_Avani_C0772788
//
//  Created by Avani Patel on 6/14/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    let userDefault = UserDefaults.standard
    
    @IBOutlet weak var tblFavPlaces: UITableView!
    var favoritePlaces: [FavoritePlace]?
    var deleteArray: [FavoritePlace]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblFavPlaces.dataSource = self
        tblFavPlaces.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.tblFavPlaces.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePlaces?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favPlace = favoritePlaces![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "favPlaceCell") as! FavPlacesTableViewCell
        cell.textLabel?.text = favPlace.address
        cell.detailTextLabel?.text = "Lat: \(favPlace.latitude) Lang: \(favPlace.longitude)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.favoritePlaces?.remove(at: indexPath.row)
            self.tblFavPlaces.deleteRows(at: [indexPath], with: .automatic)
            self.deleteArray = self.favoritePlaces
            deleteRow()
        }
//        else if editingStyle == .insert {
//
//        }
    }
    
    func getDataFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath.appending("/Favorite_Places.txt")
        return filePath
    }
    
    func loadData() {
        favoritePlaces = [FavoritePlace]()
        let filepath = getDataFilePath()
        
        if FileManager.default.fileExists(atPath: filepath) {
            do {
                let fileContent = try String(contentsOfFile: filepath)
                let contentArray = fileContent.components(separatedBy: "\n")
                for content in contentArray {
                    let favPlaceContent = content.components(separatedBy: ",")
                    if favPlaceContent.count == 3 {
                        let favPlace = FavoritePlace(latitude: Double(favPlaceContent[0]) ?? 0.0, longitude: Double(favPlaceContent[1]) ?? 0.0, address: favPlaceContent[2] )
                        favoritePlaces?.append(favPlace)
                    }
                }
                print(self.favoritePlaces?.count ?? 0)
            }
            catch {
                print(error)
            }
        }
    }
    
    func deleteRow() {
        
        
        let filePath = getDataFilePath()
        
        var saveString = ""
        for arrayItem in self.deleteArray! {
            saveString = "\(saveString)\(arrayItem.latitude),\(arrayItem.longitude),\(arrayItem.address)\n"
            do {
                userDefault.removeObject(forKey: "favPlace")
                try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
        }
    }
    
}



