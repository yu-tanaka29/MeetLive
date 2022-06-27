//
//  MapViewController.swift
//  MeetLive
//
//  Created by 田中 勇輝 on 2022/06/02.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var pinFlg: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var titleLabel: String = ""
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager!.requestWhenInUseAuthorization()
        
        self.mapView.delegate = self

//        // 東京駅の位置情報を設定（緯度: 35.681236 経度: 139.767125）
//        let latitude = 35.681236
//        let longitude = 139.767125
//        // 緯度・軽度を設定
//        let location = CLLocationCoordinate2DMake(latitude, longitude)
//        // マップビューに緯度・軽度を設定
//        self.mapView.setCenter(location, animated:true)
//        
        // 縮尺を設定
        // 縮尺を設定
        var region:MKCoordinateRegion = self.mapView.region
        region.center = self.mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        self.mapView.setRegion(region,animated:false)
        self.mapView.userTrackingMode = .followWithHeading
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.pinFlg == 1 {
            self.addPin(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    func addPin(latitude: Double, longitude: Double) {
        // ピンを生成
        let pin = MKPointAnnotation()
        // ピンのタイトル・サブタイトルをセット
        pin.title = self.userName
        pin.subtitle = self.titleLabel
        // ピンに一番上で作った位置情報をセット
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // mapにピンを表示する
        self.mapView.addAnnotation(pin)
        
        self.latitude = 0
        self.longitude = 0
        self.pinFlg = 0
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    // 許可を求めるためのdelegateメソッド
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        // 許可されてない場合
        case .notDetermined:
        // 許可を求める
            manager.requestWhenInUseAuthorization()
        // 拒否されてる場合
        case .restricted, .denied:
            // 何もしない
            break
        // 許可されている場合
        case .authorizedAlways, .authorizedWhenInUse:
            // 現在地の取得を開始
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    //アノテーションビューを返すメソッド
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         if annotation.title == "My Location"{
             return nil
         }
         //アノテーションビューを作成する。
         let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)

         //吹き出しを表示可能に。
         pinView.canShowCallout = true

         let button = UIButton()
         button.frame = CGRect(x:0,y:0,width:40,height:40)
         button.setImage(UIImage(systemName: "trash"), for: .normal)
         button.tintColor = UIColor(red: 253/255, green: 198/255, blue: 148/255, alpha: 1)
         //右側にボタンを追加
         pinView.rightCalloutAccessoryView = button
             
         return pinView
     }
    
    //吹き出しアクササリー押下時の呼び出しメソッド
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else {
            return
        }
        //右のボタンが押された場合はピンを消す。
        self.mapView.removeAnnotation(annotation)
    }
}
