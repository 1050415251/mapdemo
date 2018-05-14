//
//  ViewController.swift
//  mapdemo
//
//  Created by 国投 on 2018/5/14.
//  Copyright © 2018年 FlyKite. All rights reserved.
//

import UIKit
import MapKit
import AMapFoundationKit


class ViewController: UIViewController {

    private var mapView:MAMapView!
    private var inputTextFiled:UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initServer()
        initView()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserLocation()
    }

    fileprivate func initServer() {
        switch CLLocationManager.authorizationStatus() {
        case .denied,.restricted:
            showGetLocationInfoAlret()
            return
        default:
            break
        }
    }

    func initView() {
        addMapV()
        addInputV()
    }

    private func addMapV() {

        mapView = MAMapView(frame: self.view.bounds)

        mapView.showsScale = true
        mapView.scaleOrigin = CGPoint.init(x: 15, y: self.view.frame.height - 50)
        mapView.delegate = self
        mapView.setZoomLevel(16.0, animated: true)
        mapView.showsCompass = false
        mapView.isShowTraffic = true
        self.view.addSubview(mapView)



        let locBtn = UIButton(type:.custom)
        locBtn.frame = CGRect.init(x: self.view.frame.width - 15 -  #imageLiteral(resourceName: "location").size.width - 10, y: self.view.frame.height - 50 -  #imageLiteral(resourceName: "location").size.height - 10, width: #imageLiteral(resourceName: "location").size.width + 10, height: #imageLiteral(resourceName: "location").size.height + 10)
        locBtn.addTarget(self, action: #selector(showUserLocation), for: UIControlEvents.touchUpInside)
        locBtn.setImage(#imageLiteral(resourceName: "location"), for: UIControlState.normal)
        locBtn.backgroundColor = UIColor.white
        locBtn.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        locBtn.layer.shadowOpacity = 0.3
        locBtn.layer.masksToBounds = false
        locBtn.layer.shadowOffset = CGSize.init(width: 0, height: 4)
        locBtn.layer.cornerRadius = 5
        mapView.addSubview(locBtn)
    }

    private func addInputV() {
        let view = UIView(frame:CGRect.init(x: 30, y: UIApplication.shared.statusBarFrame.height + 10, width: self.view.frame.width - 60, height: 50))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        mapView.addSubview(view)

        inputTextFiled = UITextField(frame:CGRect.init(x: 35, y: UIApplication.shared.statusBarFrame.height + 15, width: self.view.frame.width - 70 , height: 40))
        inputTextFiled.placeholder = "请输入要搜索的范围(单位：米)"
        inputTextFiled.keyboardType = .decimalPad
        inputTextFiled.text = "3000"
        inputTextFiled.returnKeyType = .search
        inputTextFiled.backgroundColor = UIColor.white

        inputTextFiled.addTarget(self, action: #selector(inputVValueChange), for: UIControlEvents.editingChanged)
        mapView.addSubview(inputTextFiled)
    }


    @objc func showUserLocation() {
        mapView.isShowsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.setZoomLevel(13.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            self?.drawRange(rangeKm: Double(self!.inputTextFiled.text!))
        }


    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
         self.view.endEditing(true)
    }

    func drawRange(rangeKm:Double?) {
        mapView.removeOverlays(mapView.overlays)
        if rangeKm == nil {

        }else {
            let circle: MACircle = MACircle(center: mapView.centerCoordinate, radius: rangeKm!)

            mapView.add(circle)
        }

    }



}


extension ViewController : MAMapViewDelegate {


    ///显示出请求位置信息的Alret
    fileprivate func showGetLocationInfoAlret() {
        let message = "请在应用程序的\"设置-隐私-定位服务\"选项中，允许应用程序访问你的位置信息。"
        let alertVC = UIAlertController.init(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "以后", style: UIAlertActionStyle.cancel, handler: nil)

        let action2 = UIAlertAction.init(title: "设置", style: UIAlertActionStyle.default, handler: { _ in
            guard let newurl = URL.init(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(newurl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(newurl, options: [:], completionHandler: nil)
                }else {
                    UIApplication.shared.openURL(newurl)
                }
            }else {
                UIAlertView.init(title: "操作失败，请手动操作", message: nil, delegate: nil, cancelButtonTitle: "我知道了").show()
            }
        })

        alertVC.addAction(action)
        alertVC.addAction(action2)
        self.present(alertVC, animated: true, completion: nil)

    }

    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false
        mapView.update(r)
    }


    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {

    }

    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        self.mapView.removeFromSuperview()
        self.view.addSubview(mapView)

    }

    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {


    }

    func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
        mapView.setCenter(coordinate, animated: true)
        drawRange(rangeKm: Double(inputTextFiled.text!))
    }

    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MACircle.self) {
            let renderer: MACircleRenderer = MACircleRenderer(overlay: overlay)
            renderer.lineWidth = 1.0
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.4)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)

            return renderer
        }
        return nil
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAUserLocation.self) {

        }
        return nil
    }


}

extension ViewController:UITextFieldDelegate {

    @objc func inputVValueChange() {
        if !checklegitimate(inputTextFiled.text!) {
            inputTextFiled.text! = getValibleInfo(inputTextFiled.text!)
        }
    }

    func getValibleInfo(_ info:String) -> String {
        if let _ = Double(info) {
            return info
        }else {
            let newinfo = (info as NSString).substring(to: info.length - 1)
            return getValibleInfo(newinfo)
        }

    }

    //TODO: 校准输入金额
    func checklegitimate(_ info:String) -> Bool {
        if info == "" {
            return true
        }
        guard let _ = Double(info) else {
            return false
        }

        //第一位是.不允许
        if info == "." {
            return false
        }
        let doublecount = info.components(separatedBy: ".").count

        //TODO: 第一位以0开头且位数大于2
        if (info.hasPrefix("0") && info.length > 1)  && !(info.length > 1 && doublecount == 2)  {
            return false
        }
        //TODO: 有以为小数点后超出两位则不能显示
        if  doublecount == 2 {
            if (info as NSString).range(of: ".").location  < info.length - 3 {
                return false
            }
        }
        if doublecount > 2 {
            return false
        }

        return true
    }
}


extension String {

    var length:Int {
        return self.count
    }

}































