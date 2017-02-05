//
//  RxCoreLocationTests.swift
//  RxCoreLocationTests
//
//  Created by Keegan Rush on 2017/02/05.
//  Copyright © 2017 shnapped. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
import RxTest
@testable import RxCoreLocation

class RxCoreLocationTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    var serviceUnderTest: LocatorImplementation!
    
    var mockLocationManager = MockLocationManager()
    
    override func setUp() {
        super.setUp()
        serviceUnderTest = LocatorImplementation(locationManager: mockLocationManager)
    }
    
    override func tearDown() {
        mockLocationManager.verify()
        mockLocationManager.reset()
        super.tearDown()
    }
    
    func testThatErrorIsSubmittedInObservableWhenLocationAccessIsDenied() {
        mockLocationManager.expectRequestWhenInUseAuthorization(setNewValueTo: .denied)
        
        let actualLocationsObservable = serviceUnderTest.findLocation()
        
        let expectedLocationsObservable = Observable<CLLocation>.create { (observer) -> Disposable in
            observer.onError(LocationAccessDeniedError())
            return Disposables.create()
        }
        
        assertObservablesAreEqual(expectedLocationsObservable, actualLocationsObservable)
    }
    
    func testThatErrorIsSubmittedInObservableWhenLocationAccessIsRestricted() {
        mockLocationManager.expectRequestWhenInUseAuthorization(setNewValueTo: .restricted)
        
        let actualLocationsObservable = serviceUnderTest.findLocation()
        
        let expectedLocationsObservable = Observable<CLLocation>.create { (observer) -> Disposable in
            observer.onError(LocationAccessDeniedError())
            return Disposables.create()
        }
        
        assertObservablesAreEqual(expectedLocationsObservable, actualLocationsObservable)
    }
    
    func testThatLocatorRequestsAuthorizationWhenNotAuthorizedAndGivesLocationIfSuccessful() {
        MockLocationManager.stubbedAuthorizationStatus = .notDetermined
        mockLocationManager.expectRequestWhenInUseAuthorization(setNewValueTo: .authorizedWhenInUse)
        
        let expectedLocations = [CLLocation(latitude: 3, longitude: 6), CLLocation(latitude: 31.34, longitude: 65.23), CLLocation(latitude: 31.23, longitude: 43)]
        mockLocationManager.expectStartUpdatingLocation(setLocationsTo: expectedLocations)
        
        let expectedLocationsObservable = Observable<CLLocation>.of(expectedLocations.last!)
        let actualLocationsObservable = serviceUnderTest.findLocation()
        
        assertObservablesAreEqual(expectedLocationsObservable, actualLocationsObservable)
    }
    
    private func assertObservablesAreEqual<T: Equatable>(_ observable1: Observable<T>, _ observable2: Observable<T>) {
        let scheduler = TestScheduler(initialClock: 0)
        
        let testableObserver1 = scheduler.createObserver(T.self)
        observable1.subscribe(testableObserver1).addDisposableTo(disposeBag)
        
        let testableObserver2 = scheduler.createObserver(T.self)
        observable2.subscribe(testableObserver2).addDisposableTo(disposeBag)
        
        scheduler.start()
        
        let areEventsCountEqual = testableObserver1.events.count == testableObserver2.events.count
        guard areEventsCountEqual else {
            XCTAssertTrue(areEventsCountEqual, "Counts of events in observables are not equal")
            return
        }
        
        for index in 0..<testableObserver1.events.count {
            XCTAssertTrue(testableObserver1.events[index] == testableObserver2.events[index])
        }
    }
    
}
