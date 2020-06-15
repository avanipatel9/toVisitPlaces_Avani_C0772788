//
//  MapVC.swift
//  toVisitPlaces_Avani_C0772788
//
//  Created by Avani Patel on 6/15/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var travelModeSegment: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        checkLocationServices()

    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //startTrackingUserLocation()
            break
        case .denied:
            //Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show them alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    @IBAction func travelModeSegment(_ sender: UISegmentedControl) {
    }
    
    @IBAction func zoomInBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func zoomOutBtnClick(_ sender: UIButton) {
    }
    
    @IBAction func drawLocationBtnClick(_ sender: UIButton) {
    }
}

extension MapVC: CLLocationManagerDelegate {
    
}

extension MapVC: MKMapViewDelegate {
    
}
