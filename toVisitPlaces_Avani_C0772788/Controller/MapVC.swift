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
    let regionInMeters: Double = 10000
    
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
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
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
    
     func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
        }
    
    @IBAction func travelModeSegment(_ sender: UISegmentedControl) {
    }
    
    @IBAction func zoomInBtnClick(_ sender: UIButton) {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/2, longitudeDelta: mapView.region.span.longitudeDelta/2)
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOutBtnClick(_ sender: UIButton) {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*2, longitudeDelta: mapView.region.span.longitudeDelta*2)
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func drawLocationBtnClick(_ sender: UIButton) {
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let location = locations.last else { return }

               let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

               let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)

               mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

extension MapVC: MKMapViewDelegate {
    
}
