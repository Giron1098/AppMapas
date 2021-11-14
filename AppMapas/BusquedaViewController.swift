//
//  BusquedaViewController.swift
//  AppMapas
//
//  Created by Mac4 on 14/11/21.
//

import UIKit
import MapKit

class BusquedaViewController: UIViewController {
    
    @IBOutlet weak var SB_Busqueda: UISearchBar!
    @IBOutlet weak var MV_MapaBusqueda: MKMapView!
    @IBOutlet weak var LBL_MapType: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SB_Busqueda.delegate = self
    }
    
    @IBAction func BTN_ChangeMapView(_ sender: UIButton) {
        
        if MV_MapaBusqueda.mapType == .standard
        {
            LBL_MapType.text = "Satelite"
            MV_MapaBusqueda.mapType = .satellite
        } else if MV_MapaBusqueda.mapType == .satellite
        {
            LBL_MapType.text = "Estándar"
            MV_MapaBusqueda.mapType = .standard
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
                
                self.SB_Busqueda.text = ""
                
            } else {
                print("Ubicación no encontrada")
                
                self.showErrorAlert()
                
                self.SB_Busqueda.text = ""
                
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
}
