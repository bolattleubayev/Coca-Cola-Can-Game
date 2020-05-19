//
//  MapViewController.swift


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let colaPlaces = Constants.colaPlaces
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        return
    }
        
    @IBOutlet var mapView: MKMapView!
    
    var nearUserLocationAnnotation: [MKPointAnnotation] = []
    
    @IBAction func showNearby(sender: UIButton) {
        
        var nearbyAnnotations: [MKAnnotation] = []
        
        if self.colaPlaces.count > 0 {
            for item in colaPlaces {
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.subtitle = item.phone
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                
                // Get the distance to the placemark
                if let userCoordinates = mapView.userLocation.location?.coordinate {
                    let euclidianDistance = sqrt(pow(item.latitude - userCoordinates.latitude, 2) + pow((item.longitude - userCoordinates.longitude), 2))
                    
                    if euclidianDistance < 0.01 {
                        nearUserLocationAnnotation.append(annotation)
                    }
                    
                    print("Distance to \(item.name) is \(euclidianDistance)")
                }
                
                
                nearbyAnnotations.append(annotation)
            }
        }
        
        self.mapView.showAnnotations(nearbyAnnotations, animated: true)
        
    }
    
    let locationManager = CLLocationManager()
    var currentPlacemark: CLPlacemark?
    
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.modifyNavigationController(navigationController: navigationController)
        // Show the current user's location
        mapView.showsUserLocation = true
        
        // Request for a user's authorization for location services
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        
        mapView.delegate = self
        if #available(iOS 9.0, *) {
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.showsTraffic = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MKMapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if nearUserLocationAnnotation.contains(view.annotation as! MKPointAnnotation) {
            performSegue(withIdentifier: "showGame", sender: view)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        // Reuse the annotation if possible
        var annotationView: MKAnnotationView?

        if #available(iOS 11.0, *) {
            var markerAnnotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if markerAnnotationView == nil {
                markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                markerAnnotationView?.canShowCallout = true
            }
            markerAnnotationView?.glyphText = "🥤"
            
            if nearUserLocationAnnotation.contains(annotation as! MKPointAnnotation) {
                markerAnnotationView?.markerTintColor = UIColor.orange
            } else {
                markerAnnotationView?.markerTintColor = UIColor.gray
            }
            
            

            annotationView = markerAnnotationView

        } else {

            var pinAnnotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinAnnotationView?.canShowCallout = true
                pinAnnotationView?.pinTintColor = UIColor.orange
            }

            annotationView = pinAnnotationView
        }
//
//        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
//        leftIconView.image = UIImage(named: colaPlace.image)
//        annotationView?.leftCalloutAccessoryView = leftIconView
        
        annotationView?.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)

        return annotationView
    }
    
}
