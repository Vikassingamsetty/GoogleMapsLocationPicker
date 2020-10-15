//
//  AddNewAddressVC.swift
//  HR Finance
//
//  Created by vikas on 24/09/20.
//  Copyright © 2020 Appcare Apple. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol LoadAddrList {
    func onTapAddAddress()
}

class AddressVC: UIViewController{
    
    //MARK:- outlets
    @IBOutlet weak var placesTf: UITextField!
    @IBOutlet weak var placesBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressTypeBtn: UIButton!
    
    //Google maps
    private var locationManager:CLLocationManager?
    private var marker = GMSMarker()
    //lat and long storage
    private var latValue:String?
    private var longValue:String?
    
    var delegate:LoadAddrList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserLocation()//getting user location
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK:- Selector
    @IBAction func cancelBtnAct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        delegate?.onTapAddAddress()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func placesBtnTapped(_ sender: Any) {
        getPlaces()
    }
    
    //places on search
    func getPlaces() {
        placesTf.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    
    
    //MARK:- getting location
    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        mapView.isMyLocationEnabled = true
        
        mapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()
        }
        
    }
    
    //MARK:-ADDING MARKER
    func addMarker(lat:Double, long:Double) {
        //Adding a marker to the view
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.map = mapView
        let locCamera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: long,
                                              zoom: 15)
        mapView.camera = locCamera
        marker.isDraggable = true
        reverseGeocoding(marker: marker)
        marker.map = mapView
    }
    
    @IBAction func tapOnmylocation(_ sender: Any) {
        mapView.clear()
        getUserLocation()
    }
    
    
    /*
    //MARK:- Get address from lat long values
    func getAddressFromLatLon(latitudeValue: String, withLongitude longituteValue: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(latitudeValue)")!
        //21.228124
        let lon: Double = Double("\(longituteValue)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]

                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }

                    print(addressString)
                    self.addressLbl.text = addressString
              }
        })

    }*/
    
    //MARK:- Reverse GeoCoding
    func reverseGeocoding(marker: GMSMarker) {
        let geocoder = GMSGeocoder()
        let coordinate = CLLocationCoordinate2DMake(Double(marker.position.latitude),Double(marker.position.longitude))
        
        var currentAddress = String()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] response , error in
            guard let self = self else{return}
            
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                
                print("Response is = \(address)")
                print("Response is = \(lines)")
                
                currentAddress = lines.joined(separator: "\n")
            }
            self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15)
            marker.title = currentAddress
            self.latValue = "\(marker.position.latitude)"
            self.longValue = "\(marker.position.longitude)"
            print(self.latValue!, self.longValue!, "pointer")
            self.addressLbl.text = currentAddress
            marker.map = self.mapView
        }
    }
   
}

//MARK:- Extensions
//location Delegate
extension AddressVC: CLLocationManagerDelegate{
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        latValue = "\(locValue.latitude)"
        longValue = "\(locValue.longitude)"
        addMarker(lat: locValue.latitude, long: locValue.longitude)
    }
    
}

//marker moving
extension AddressVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("Position of marker is = \(marker.position.latitude),\(marker.position.longitude)")
        reverseGeocoding(marker: marker)
        print("Position of marker is = \(marker.position.latitude),\(marker.position.longitude)")
    }
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("didBeginDragging")
    }
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
}

//Places for displaying it on Textfield
extension AddressVC: GMSAutocompleteViewControllerDelegate {
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    // un comment below code Only to display the address on textfield without marker
    /*
    placesTf.text = place.name
// Dismiss the GMSAutocompleteViewController when something is selected
    dismiss(animated: true, completion: nil)
    */
    
    //extra for pointing it on maps for serched location
    print("places name: \(String(describing: place.name))")
    dismiss(animated: true, completion: nil)
    
    self.mapView.clear()
    self.placesTf.text = place.name
    
    //This is used to find the coordinates for places picked
    let cord2D = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    print(cord2D,"place picked")
    
    addMarker(lat: place.coordinate.latitude, long: place.coordinate.longitude)
    
  }
func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // Handle the error
    print("Error: ", error.localizedDescription)
  }
func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    // Dismiss when the user canceled the action
    dismiss(animated: true, completion: nil)
  }
}
