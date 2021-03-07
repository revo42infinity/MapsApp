//
//  ViewController.swift
//  MapsApp
//
//  Created by owner on 2/20/21.
//

import UIKit
import MapKit //2
import CoreLocation //5
//27
import CoreData
//3
class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    //22
    @IBOutlet weak var nameTextField: UITextField!
    //22
    @IBOutlet weak var noteTextField: UITextField!
    
    //1
    @IBOutlet weak var mapView: MKMapView!
    //6
    var locationManager = CLLocationManager() //konumla ilgili olaylari baslatmak durdurmaya yariyor. aktif ettik
    
    //29
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    //52 prepare for segue ile ulasmak icin
    var selectedname = ""
    var selectedid : UUID?
    
    //66 annotation title ve subtitle olacak o yuzden degisken olarak yazalim once
    var annotationtitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //4
        mapView.delegate = self
        //7
        locationManager.delegate = self
        //8 dogruluk almak icin lokasyonun accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //9 location baslatmadan once izin al
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //bundan sonra info plist de islemi yap
        
        
        //14 location pointe basliyoruz
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
        //konum secimi icerisinde gesturerecognizer a ulasabilicem
        
        //17
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //53
        if selectedname != ""{
            //bos degil ise core datadan verileri cek
            //60
            if let uuidString = selectedid?.uuidString {
                //print(uuidString)
                //61
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                //62
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
                //63 filtreleme yapiyoruz..neyi filtreleyecegiz ve hangi degerle
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                //62
                fetchRequest.returnsObjectsAsFaults = false
                
                //64
                do {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            //65 for loop yapmak lazim. id zaten gelmisti gerek yok
                            if let name = result.value(forKey: "name") as? String {
                               //67
                                annotationtitle = name
                            }
                            if let note = result.value(forKey: "note") as? String {
                                annotationSubtitle = note //68
                                
                            }
                            if let latitude = result.value(forKey: "latitude") as? Double {
                                annotationLatitude = latitude //69
                            }
                            if let longitude = result.value(forKey: "longitude") as? Double {
                                annotationLongitude = longitude //70
                            }
                            //71
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationtitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude) //annotat coordinate vermek icin bunu olusturmak lazim
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                            nameTextField.text = annotationtitle
                            
                            noteTextField.text = annotationSubtitle
                            
                        }
                    }
                    
                    
                } catch {
                    print("error")
                }
                
                
            }
        } else {
            //yeni veri eklemeye geldi
        }
    }
    
    //15 kullanicinin tikladigi yeri oradan alacagiz o yuzden icine gesture yazdik select icine
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        //16 nasil ulasiyoruz gesture a. kullanicinn tikladigi yerde ki noktayi hesaplayip konum oalrak veriyor
        //gestureRecognizer.location(in: <#T##UIView?#>)
        
        //18 durumunu olcmek
        if gestureRecognizer.state == .began { //basladiysa ne olacagini yazalim
            //19 dokunulan noktsyi lalim
            let selectedPoint = gestureRecognizer.location(in: mapView) //mapview a dokunuluyor
            //20 dokunulan yeri koordinata dondur
            let selectedCoordinate = mapView.convert(selectedPoint, toCoordinateFrom: mapView)
            
            //30 bu deger atamasi kullanici bir yere tiklaninca olacak
            selectedLatitude = selectedCoordinate.latitude
            selectedLongitude = selectedCoordinate.longitude
            
            //21 isaretleme islemi
            let annotation = MKPointAnnotation() //haritada spesifik noktaya uyguladigimiz annotation
            annotation.coordinate = selectedCoordinate //dokunulan coordinate veriyor
            annotation.title = nameTextField.text //23 textfield i storyboardda yaptiktan sonra yazdik normalde text yazmistik buraya
            annotation.subtitle = noteTextField.text
            mapView.addAnnotation(annotation)
            
            
        }
    }
    
    
    
    
//10 konumlar guncellendi
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
       
        //11 location olusturalim
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        
        //14 bolgenin yukseklik ve genisligi icin...zoom seviyesi
        let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        //13 region olustur
        let region = MKCoordinateRegion(center: location, span: span) //center nereye merkez alacak. span
        //12 bir yere gitmek istiyorsak orayi degistirmek istiyorsak setregion kullan.
        mapView.setRegion(region, animated: true)
        
    }
    
    //24 bunu yapip entity e git
    @IBAction func savedClick(_ sender: Any) {
        //25 context alacaz
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //contexte ulasabilmek icin
        let context = appDelegate.persistentContainer.viewContext
        
        //26 ayarlarini yapalim. yeni yer olusturucaz..entity isminden emin ol
        let newplace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context) //boylece yeni yerleri kullanmaya baslayabiliriz
        //28 setvalue diyince degerleri kaydedebiliyoruz
        newplace.setValue(nameTextField.text, forKey: "name")
        newplace.setValue(noteTextField.text, forKey: "note")
        //31
        newplace.setValue(selectedLatitude, forKey: "latitude")
        newplace.setValue(selectedLongitude, forKey: "longitude")
        //32
        newplace.setValue(UUID(), forKey: "id")
        
        //33
        do{
            try context.save()
            print("saved")
        } catch {
            print("error")
        }
        
        
    }
    

}

