//
//  ViewController.swift
//  A1_iOS_Kirna_779568
//
//  Created by user165337 on 1/25/21.
//  Copyright © 2021 user165337. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directionBtn: UIButton!
    
     // create location manager
       var locationMnager = CLLocationManager()
       
       // destination variable
       var destination: CLLocationCoordinate2D!
    let places = Place.getPlaces()
    override func viewDidLoad() {
    
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         // 1st step is to define latitude and longitude
                let latitude: CLLocationDegrees = 43.64
                let longitude: CLLocationDegrees = -79.38
                
                // 2nd step is to display the marker on the map
                displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here")
        // call
        addDoubleTap()
        // call
        addPolyline()

        //call
       addPolygon()
        // giving the delegate of MKMapViewDelegate to this class
        map.delegate = self
        
       addAnnotationsForPlaces()
    //    removePin()
    }
    // route
    @IBAction func route(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
                
                let sourcePlaceMark = MKPlacemark(coordinate: locationMnager.location!.coordinate)
                let destinationPlaceMark = MKPlacemark(coordinate: destination)
                
                // request a direction
                let directionRequest = MKDirections.Request()
                
                // assign the source and destination properties of the request
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
                
                // transportation type
                directionRequest.transportType = .automobile
                
                // calculate the direction
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let directionResponse = response else {return}
                    // create the route
                    let route = directionResponse.routes[0]
                    // drawing a polyline
                    self.map.addOverlay(route.polyline, level: .aboveRoads)
                    
                    // define the bounding map rect
                    let rect = route.polyline.boundingMapRect
                    self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                    
        //            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            }
    //MARK: - add annotations for the places
        func addAnnotationsForPlaces() {
            
            map.addAnnotations(places)
            
        }
    //MARK: - polyline method
           func addPolyline() {
            removePin()
            let coordinates = places.map{$0.coordinate}
               let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
               map.addOverlay(polyline)
           }
           
   
    //MARK: - polygon method
    func addPolygon() {
        map.isZoomEnabled = true
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
        removePin()
    removeOverlay()
        
    }
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {

        //removePin()
        // removeOverlay()
       // map.isZoomEnabled = false
        // add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "a"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        if annotation.accessibilityElementCount() == 3{
        addPolygon()
        }else if annotation.accessibilityElementCount() == 4{
            removePin()
           removeOverlay()
            addDoubleTap()
        }
    destination = coordinate
    directionBtn.isHidden = false
        
    }
    //MARK: - remove pin from map
        func removePin() {
            for annotation in map.annotations {
                map.removeAnnotation(annotation)
            }
            
    //        map.removeAnnotations(map.annotations)
        }
    func removeOverlay(){
        for overlay in map.overlays{
            map.removeOverlay(overlay)
        }
    }
        
            //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 1
        let lngDelta: CLLocationDegrees = 1
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        map.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
}
extension ViewController: MKMapViewDelegate {
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "a":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "a to b 40 km")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "b":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bto c 60km")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        case "c":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "c to a 80km")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        default:
            return nil
        }
    }
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Favorite", message: "A nice place to visit", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - rendrer for overlay func
       func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if  overlay is MKPolyline {
        removePin()
        let rendrer = MKPolylineRenderer(overlay: overlay)
        rendrer.strokeColor = UIColor.green
        rendrer.lineWidth = 3
        return rendrer
    }else if overlay is MKPolygon {
        
    let rendrer = MKPolygonRenderer(overlay: overlay)
    rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
    rendrer.strokeColor = UIColor.red
    rendrer.lineWidth = 2
        return rendrer
        
        }
        return MKOverlayRenderer()
    
}
}

        
    

