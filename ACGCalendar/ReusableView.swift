//
//  Reusable.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/13/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import Foundation

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: type(of: self))
    }
}
