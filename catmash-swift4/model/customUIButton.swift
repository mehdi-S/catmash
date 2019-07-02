//
//  customUIButton.swift
//  catmash-swift4
//
//  Created by Mehdi Silini on 24/10/2017.
//  Copyright © 2017 Mehdi Silini. All rights reserved.
//

import UIKit

class customUIButton: UIButton {
    override var clipsToBounds: Bool {
        set {
            super.imageView?.clipsToBounds = true
        }
        get {
            return super.imageView!.clipsToBounds
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = self.bounds
        self.imageView?.contentMode = .scaleAspectFill
    }
}
