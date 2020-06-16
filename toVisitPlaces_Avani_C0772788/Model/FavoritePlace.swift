//
//  Favorite.swift
//  toVisitPlaces_Avani_C0772788
//
//  Created by Avani Patel on 6/15/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import Foundation

class FavoritePlace {
    var latitude: Double
    var longitude: Double
    var address: String
    
    init(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
}
