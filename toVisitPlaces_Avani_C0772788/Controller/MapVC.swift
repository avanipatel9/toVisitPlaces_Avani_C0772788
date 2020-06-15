//
//  MapVC.swift
//  toVisitPlaces_Avani_C0772788
//
//  Created by Avani Patel on 6/15/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var travelModeSegment: UISegmentedControl!
    
    let regionInMeters: Double = 10000
    let locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    var travelMode: String = "Drive"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        checkLocationServices()
        addDoubleTap()

    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
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
       let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        if sender.selectedSegmentIndex == 0 {
            travelMode = "D"
        }
        else{
            travelMode = "W"
        }
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
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        //draw route
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        
        directionRequest.requestsAlternateRoutes = true
        
        if(travelMode == "D") {
            directionRequest.transportType = .automobile
        }
        else {
            directionRequest.transportType = .walking
        }
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            let route = unwrappedResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = route.distance
                
                let alert = UIAlertController(title: "Let's go", message: "Distnace : \(distance) KM", preferredStyle: .alert)
                       let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                       alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
        }
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
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destination = coordinate
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    //MARK: - add viewFor annotation method
       func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
           if annotation is MKUserLocation {
               return nil
           }
           // add custom annotation with image
               let pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
               pinAnnotation.image = UIImage(systemName: "mappin")
               pinAnnotation.canShowCallout = true
               pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
               return pinAnnotation
           }
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Place", message: "Welcome", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            if travelModeSegment.selectedSegmentIndex == 0
            {
                rendrer.strokeColor = UIColor.red
            }
            else
            {
                rendrer.strokeColor = UIColor.blue
                rendrer.lineDashPattern = [0,4]
            }
            rendrer.lineWidth = 3
            return rendrer
            
        }
        return MKOverlayRenderer()
    }
}
