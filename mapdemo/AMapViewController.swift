//
//  AMapViewController.swift
//  mapdemo
//
//  Created by 国投 on 2018/5/14.
//  Copyright © 2018年 FlyKite. All rights reserved.
//

import Foundation
import MapKit

class AMAPViewController: UIViewController {

    var mapView:MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func initView() {
        mapView = MKMapView(frame: self.view.bounds)
        self.view.addSubview(mapView)
    }

}
