//
//  ViewController.swift
//  RevGeoTest
//
//  Created by Alexander v. Below on 22.12.16.
//  Copyright © 2016 Alexander von Below. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    var geocoder : CLGeocoder!
    var geocodingQueue = DispatchQueue(label: "com.vonbelow.geolocation")

    @IBOutlet weak var label1: UILabel!

    func getGeolocation (_ location: CLLocation, completionHandler:@escaping CoreLocation.CLGeocodeCompletionHandler) {
        
        geocodingQueue.sync {
            let semaphore = DispatchSemaphore(value: 0);
            
            if self.geocoder == nil {
                self.geocoder = CLGeocoder()
            }
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarkArray, error) in
                semaphore.signal()
                completionHandler(placemarkArray, error)
            })
            // MARK: If I wait for the semaphore, the block above is
            // never executed. If I comment it out, everything is fine
            semaphore.wait()
        }
    }
    
    @IBAction func degeocode1(_ sender: UIButton) {
        let location = CLLocation(latitude: 37.331695, longitude: -122.0322854)
        self.getGeolocation(location) { (placemarkArray, error) in
            if let error = error {
                self.label1.text = error.localizedDescription
            }
            else if let placemark = placemarkArray?.first {
                
                let addressLines = placemark.addressDictionary?["FormattedAddressLines"]
                
                self.label1.text = (addressLines as AnyObject).componentsJoined(by: ", ")
            }
            else {
                self.label1.text = ""
            }

        }
    }

}

