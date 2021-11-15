//
//  BusquedaViewController.swift
//  AppMapas
//
//  Created by Mac4 on 14/11/21.
//

import UIKit
import MapKit
import CoreLocation

class BusquedaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var SB_Busqueda: UISearchBar!
    @IBOutlet weak var MV_MapaBusqueda: MKMapView!
    @IBOutlet weak var B_BTN_MapView: UIBarButtonItem!
    @IBOutlet weak var LBL_MapType: UILabel!
    
    //Manager para usar el GPS
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SB_Busqueda.delegate = self
        manager.delegate = self
        MV_MapaBusqueda.delegate = self
        
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        //Mejorar la presición para la ubicación
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Monitorear la ubicación del usuario
        manager.startUpdatingLocation()
    }
    
    //MARK:-Trazado de la ruta
    
    func trazadoRuta(coordenadasDestino:CLLocationCoordinate2D)
    {
        guard let coordenadasOrigen = manager.location?.coordinate else { return }
        
        //Creamos lugar de origen-destino
        let origenPlaceMK = MKPlacemark(coordinate: coordenadasOrigen)
        let destinoPlaceMK = MKPlacemark(coordinate: coordenadasDestino)
        
        //Crear objeto MapKitItem
        let origenItem = MKMapItem(placemark: origenPlaceMK)
        let destinoItem = MKMapItem(placemark: destinoPlaceMK)
        
        //Crear solicitud de Ruta
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = origenItem
        solicitudDestino.destination = destinoItem
        
        //Definir el medio de transporte
        solicitudDestino.transportType = .automobile
        solicitudDestino.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            //Crear respeusta en variable segura
            guard let respuestaSegura = respuesta else {
                if let error = error
                {
                    print("Error al calcular la ruta \(error.localizedDescription)")
                    self.showRouteErrorAlert()
                }
                return
            }
            print(respuestaSegura.routes.count)
            let ruta = respuestaSegura.routes[0]
            
            //Agregar superposición al mapa
            self.MV_MapaBusqueda.addOverlay(ruta.polyline)
            self.MV_MapaBusqueda.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
            
        } //Fin calcular ruta
    }
    
    //Mostrar la ruta encima del mapa
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .orange
        return render
    }
    
    //Métodos del CLLocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Búsqueda - Ubicación obtenida")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Búsqueda - Error al obtener la ubicación")
    }
    

    
    @IBAction func B_BTN_ChangeMapView(_ sender: UIBarButtonItem) {
        
        if MV_MapaBusqueda.mapType == .standard
        {
            LBL_MapType.text = "Satelite"
            MV_MapaBusqueda.mapType = .satellite
            B_BTN_MapView.image = UIImage(systemName: "map.fill")
        } else if MV_MapaBusqueda.mapType == .satellite
        {
            LBL_MapType.text = "Estándar"
            MV_MapaBusqueda.mapType = .standard
            B_BTN_MapView.image = UIImage(systemName: "map")
        }
        
    }
    
    @IBAction func B_BTN_TrazarRuta(_ sender: UIBarButtonItem) {
        
        if let direccion = SB_Busqueda.text
        {
            let geocoder = CLGeocoder()
            
            //LIMPIAR MAPA AL REALIZAR UN NUEVO TRAZADO DE RUTAS
            let overlays = MV_MapaBusqueda.overlays
            let annotations = MV_MapaBusqueda.annotations
            
            MV_MapaBusqueda.removeOverlays(overlays)
            MV_MapaBusqueda.removeAnnotations(annotations)
            
            geocoder.geocodeAddressString(SB_Busqueda.text!) { (places: [CLPlacemark]?, error: Error?) in
                
                //Crear destino para la ruta
                guard let ruta = places?.first?.location else { return }
                if error == nil
                {
                    //Mostrar dirección
                    let place = places?.first
                    print("Trazar ruta - Lugar: \(places!)")
                    
                    //Hacer zoom al lugar buscado
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (place?.location?.coordinate)!
                    
                    //Se accede a algunos parametros espcificos del arreglo CLPlacemark para personalizar la anotacion
                    
                    if let nombre = places?[0].name
                    {
                        if let pais = places?[0].country
                        {
                            if let estado = places?[0].administrativeArea
                            {
                                anotacion.title = "\(nombre), \(estado), \(pais)"
                            }
                        }
                    }
                    
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
                    let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                    
                    self.MV_MapaBusqueda.setRegion(region, animated: true)
                    self.MV_MapaBusqueda.addAnnotation(anotacion)
                    self.MV_MapaBusqueda.selectAnnotation(anotacion, animated: true)
                    
                    //Mandamos llamar el metodo para trazar la ruta
                    self.trazadoRuta(coordenadasDestino: ruta.coordinate)
                    self.MV_MapaBusqueda.showsUserLocation = true
                    
                } else {
                    print("Ubicación no encontrada")
                    
                    self.showErrorAlert()
                    
                    
                }
            }
        }
        
    }
    

    
    
    //OCULTAR EL TECLADO
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension BusquedaViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Ocultar teclado despues de presionar el boton de busqueda
        SB_Busqueda.resignFirstResponder()
        
        print("Se buscó algo")
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(SB_Busqueda.text!) { (places: [CLPlacemark]?, error: Error?) in
            if error == nil
            {
                //Mostrar dirección
                let place = places?.first
                print("Lugar: \(places!)")
                
                //Hacer zoom al lugar buscado
                let anotacion = MKPointAnnotation()
                anotacion.coordinate = (place?.location?.coordinate)!
                
                //Se accede a algunos parametros espcificos del arreglo CLPlacemark para personalizar la anotacion
                
                if let nombre = places?[0].name
                {
                    if let pais = places?[0].country
                    {
                        if let estado = places?[0].administrativeArea
                        {
                            anotacion.title = "\(nombre), \(estado), \(pais)"
                        }
                    }
                }
                
                
                let span = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                
                self.MV_MapaBusqueda.setRegion(region, animated: true)
                self.MV_MapaBusqueda.addAnnotation(anotacion)
                self.MV_MapaBusqueda.selectAnnotation(anotacion, animated: true)
                
                
            } else {
                print("Ubicación no encontrada")
                
                self.showErrorAlert()
                
                
            }
        }
        
    }
    
    
    
    //Funcion para mostrar un alert en caso de que se encuentre algun error al buscar la ubicacion deseada
    func showErrorAlert ()
    {
        let alerta = UIAlertController(title: "Hubo un problema", message:"Ubicación no encontrada", preferredStyle: .alert)
        
        let actionAceptar = UIAlertAction(title: "Aceptar", style:.default, handler: nil)
        
        alerta.addAction(actionAceptar)
        
        present(alerta, animated: true, completion: nil)
    }
    
    //Funcion para mostrar un alert en caso de que se encuentre algun error al trazar la ruta a la ubicación deseada
    func showRouteErrorAlert ()
    {
        let alerta = UIAlertController(title: "Hubo un problema", message:"Error al trazar la ruta", preferredStyle: .alert)
        
        let actionAceptar = UIAlertAction(title: "Aceptar", style:.default, handler: nil)
        
        alerta.addAction(actionAceptar)
        
        present(alerta, animated: true, completion: nil)
    }
}
