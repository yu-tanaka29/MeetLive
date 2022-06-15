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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager!.requestWhenInUseAuthorization()

//        // 東京駅の位置情報を設定（緯度: 35.681236 経度: 139.767125）
//        let latitude = 35.681236
//        let longitude = 139.767125
//        // 緯度・軽度を設定
//        let location = CLLocationCoordinate2DMake(latitude, longitude)
//        // マップビューに緯度・軽度を設定
//        self.mapView.setCenter(location, animated:true)
//        
//        // 縮尺を設定
//        var region = mapView.region
//        region.center = location
//        region.span.latitudeDelta = 0.02
//        region.span.longitudeDelta = 0.02
//        // マップビューに縮尺を設定
//        self.mapView.setRegion(region, animated:true)
        
    }
    
    func addPin(latitude: Double, longitude: Double) {
        // ピンを生成
        let pin = MKPointAnnotation()
        // ピンのタイトル・サブタイトルをセット
        pin.title = "ピン立て"
        pin.subtitle = "たてました"
        // ピンに一番上で作った位置情報をセット
        pin.coordinate = CLLocationCoordinate2D(latitude: 35.696, longitude: 139.758)
        // mapにピンを表示する
        self.mapView.addAnnotation(pin)
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
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
    
}
