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
    
    let userDefault = UserDefaults.standard
    let regionInMeters: Double = 10000
    let locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    var travelMode: String = "Drive"
    var favoritePlaces: [FavoritePlace]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
        
        loadData()
        
        checkLocationServices()
        addDoubleTap()

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
            } catch {
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let favPlaceVC = segue.destination as? ViewController {
            favPlaceVC.favoritePlaces = self.favoritePlaces
        }
    }
    
    @objc func saveData() {
        let filePath = getDataFilePath()
        
        var saveString = ""
        for favPlace in favoritePlaces! {
            saveString = "\(saveString)\(favPlace.latitude),\(favPlace.longitude),\(favPlace.address)\n"
        }
        do {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
            userDefault.setValue(saveString, forKey: "favPlace")
               } catch {
                   print(error)
               }
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
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
//        removePin()
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
    
    
    
}

extension MapVC: MKMapViewDelegate {
    
    func geocode()  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: destination.latitude, longitude: destination.longitude)) {  placemark, error in
           if let error = error as? CLError {
               print("CLError:", error)
               return
            }
           else if let placemark = placemark?[0] {
            
            var address = ""
            
            if let addressName = placemark.name {
                address += addressName
                        }
            if let sublocality = placemark.subLocality {
                address += sublocality
                        }
            if let locality = placemark.locality {
                address += locality
                      }
            if let country = placemark.country {
               address += country
                      }
            
            let favPlace = FavoritePlace(latitude: self.destination.latitude, longitude: self.destination.longitude, address: address)
          
            self.favoritePlaces?.append(favPlace)
            self.saveData()
            self.navigationController?.popToRootViewController(animated: true)
            }

        }
    }
    
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
        let alertController = UIAlertController(title: "Your Favorite Place", message: "Are you sure you want to add this place to your Favorite Places?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style:  .default, handler: { (UIAlertAction) in
                           self.geocode()
                           }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
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
