//
//  Locator.swift
//  RxCoreLocation
//
//  Created by Keegan Rush on 2017/02/06.
//  Copyright © 2017 shnapped. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol Locator {
    func findLocation() -> Observable<CLLocation>
}

struct LocationAccessDeniedError: Error {
    
}
