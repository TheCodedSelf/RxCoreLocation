//
//  LocatorImplementation.swift
//  RxCoreLocation
//
//  Created by The Coded Self on 2017/02/06.
//  Copyright © 2017 The Coded Self. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

class LocatorImplementation: NSObject, Locator, CLLocationManagerDelegate {
    
    var locationsObservable = ReplaySubject<CLLocation>.create(bufferSize: 1)
    let locationManager: CLLocationManager
    
    convenience override init() {
        self.init(locationManager: CLLocationManager())
    }
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    func findLocation() -> Observable<CLLocation> {
        locationsObservable = ReplaySubject<CLLocation>.create(bufferSize: 1)
        locationManager.requestWhenInUseAuthorization()
        return locationsObservable
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .restricted:
            fallthrough
        case .denied:
            locationsObservable.onError(LocationAccessDeniedError())
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            locationsObservable.onNext($0)
        }
        
        locationsObservable.onCompleted()
        manager.stopUpdatingLocation()
    }
}
