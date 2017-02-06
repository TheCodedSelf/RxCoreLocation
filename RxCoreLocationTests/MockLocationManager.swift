//
//  MockLocationManager.swift
//  RxCoreLocation
//
//  Created by Keegan Rush on 2017/02/06.
//  Copyright © 2017 shnapped. All rights reserved.
//

import Foundation
import CoreLocation
import XCTest

class MockLocationManager: CLLocationManager {
    
    let isStrict: Bool
    let requestWhenInUseAuthorizationExpectation = "requestWhenInUseAuthorization"
    let startUpdatingLocationExpectation = "startUpdatingLocationExpectation"
    
    var expectations = [String : Int]()
    var stubbedLocations = [CLLocation]()
    
    static var stubbedAuthorizationStatus = CLAuthorizationStatus.notDetermined
    
    required init(isStrict: Bool = true) {
        self.isStrict = isStrict
    }
    
    override static func authorizationStatus() -> CLAuthorizationStatus {
        return stubbedAuthorizationStatus
    }
    
    func expectRequestWhenInUseAuthorization(setNewValueTo newValue: CLAuthorizationStatus) {
        expect(requestWhenInUseAuthorizationExpectation)
        MockLocationManager.stubbedAuthorizationStatus = newValue
    }
    
    func expectStartUpdatingLocation(setLocationsTo newLocations: [CLLocation]) {
        expect(startUpdatingLocationExpectation)
        stubbedLocations = newLocations
    }
    
    func verify() {
        for (expectation, count) in expectations {
            XCTAssertTrue(count <= 0, "Expectation \(expectation) should have been executed \(count) more times")
        }
    }
    
    func reset() {
        for expectation in expectations.keys {
            expectations[expectation] = 0
        }
    }
    
    override func requestWhenInUseAuthorization() {
        fire(expectation: requestWhenInUseAuthorizationExpectation)
        delegate?.locationManager?(self, didChangeAuthorization: MockLocationManager.stubbedAuthorizationStatus)
    }
    
    
    override func startUpdatingLocation() {
        fire(expectation: startUpdatingLocationExpectation)
        delegate?.locationManager?(self, didUpdateLocations: stubbedLocations)
    }
    
    private func expect(_ expectation: String) {
        let value = expectations[expectation] ?? 0
        expectations[expectation] = value + 1
    }
    
    private func fire(expectation: String, file: StaticString = #file, line: UInt = #line) {
        var expectationCount = expectations[expectation] ?? 0
        expectationCount -= 1
        expectations[expectation] = expectationCount
        
        if isStrict {
            XCTAssertTrue(expectationCount >= 0, "Did not expect \(expectation) to be fired", file: file, line: line)
        }
    }
    
}
