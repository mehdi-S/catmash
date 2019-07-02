//
//  customImageView.swift
//  catmash-swift4
//
//  Created by Mehdi Silini on 24/10/2017.
//  Copyright © 2017 Mehdi Silini. All rights reserved.
//

import UIKit

class customImageView: UIImageView {
    override var clipsToBounds: Bool {
        set {
            super.clipsToBounds = true
        }
        get {
            return super.clipsToBounds
        }
    }
}
