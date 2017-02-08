//
//  Locator.swift
//  RxCoreLocation
//
//  Created by The Coded Self on 2017/02/06.
//  Copyright © 2017 The Coded Self. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol Locator {
    func findLocation() -> Observable<CLLocation>
}

struct LocationAccessDeniedError: Error {
    
}
