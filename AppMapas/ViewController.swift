//
//  ViewController.swift
//  AppMapas
//
//  Created by Mac4 on 09/11/21.
//

import UIKit
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var MV_Mapa: MKMapView!
    
    var manager = CLLocationManager()
    var latitud:CLLocationDegrees!
    var longitud:CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegados
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation() //Comenzar la actualización de la ubicación
    }
    
    @IBAction func B_BTN_Location(_ sender: UIBarButtonItem) {
        if let LAT = self.latitud
        {
            if let LON = self.longitud
            {
                let alerta = UIAlertController(title: "Ubicación", message: "Tus coordenadas actuales son:\n LAT: \(LAT) \nLON: \(LON)", preferredStyle: .alert)
                
                let actionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                let actionVerMas = UIAlertAction(title: "Ver en el Mapa", style: .default) { (_) in
                    //Hacer zoom a la ubicación en el mapa
                    let localizacion = CLLocationCoordinate2DMake(LAT, LON)
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: localizacion, span: span)
                    self.MV_Mapa.setRegion(region, animated: true)
                    
                    self.MV_Mapa.showsUserLocation = true
                }
                
                alerta.addAction(actionAceptar)
                alerta.addAction(actionVerMas)
                
                present(alerta, animated: true, completion: nil)
            }
        }
    }
    //MARK:- Obtener la ubicación
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first
        {
            print("Mi ubicación - Ubicación obtenida")
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
        } else {
            print("Mi ubicación - Error al obtener la ubicación")
        }
    }

}

