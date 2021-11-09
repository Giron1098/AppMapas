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
                let alerta = UIAlertController(title: "Ubicación", message: "Tus coordenadas actuales son:\n LAT: \(LAT), LON: \(LON)", preferredStyle: .alert)
                
                let actionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                let actionCancelar = UIAlertAction(title: "Ver más...", style: .default, handler: nil)
                
                alerta.addAction(actionAceptar)
                alerta.addAction(actionCancelar)
                
                present(alerta, animated: true, completion: nil)
            }
        }
    }
    //MARK:- Obtener la ubicación
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first
        {
            print("Ubicación obtenida")
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
        } else {
            print("Error al obtener la ubicación")
        }
    }

}

