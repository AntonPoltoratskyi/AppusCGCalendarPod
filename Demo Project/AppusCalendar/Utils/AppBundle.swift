//
//  AppBundle.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/3/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

class AppBundle {
    
    static let shared = AppBundle()
    
    var defaultBundle: Bundle {
        return Bundle(for: type(of: self))
    }
}
