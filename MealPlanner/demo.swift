//
//  demo.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 04.06.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

public class demovc : UIViewController {
    static var count = 0
    
    public override func loadView() {
        let label = UILabel(frame: CGRectZero)
        label.text = "\(demovc.count+1)"
        label.textAlignment = .Center
        demovc.count++
        self.view = label
    }
}
