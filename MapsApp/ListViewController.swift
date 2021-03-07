//
//  ListViewController.swift
//  MapsApp
//
//  Created by owner on 3/7/21.
//

import UIKit
//40
import CoreData
//34
class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //48
    var nameDizisi = [String]()
    var idDizisi = [UUID] ()
    
    //55 segue icin
    var selectedPlacename = ""
    var selectedplaceid : UUID?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     //35
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //38 arti butonu
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusclicked))
        
        //41
        getdata()
        
    }
    //42
    func getdata() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //43 request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        //44
        do {
            //45 context.fetch bize sonuclarin oldugu dizi veriyordu. bu dizi icinde any dizisi veriyor ama nsmanageobjecte getirmek istiyoruz
            let results = try context.fetch(request)
            
            if results.count > 0 { //gelen sonuc var ise
                
                //51 for lopa girmeden bosaltalim
                nameDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                    
                
                //46
                for result in results as! [NSManagedObject] { //results any verdigi icin nsmanagedobject olarak cast ettik
                    if let name = result.value(forKey: "name") as? String {
                        //49
                        nameDizisi.append(name)
                        
                    }
                    
                    //47
                    if let id = result.value(forKey: "id") as? UUID {
                        //46 ve 47 de isim ve id aldik bunlari diziye kaydedelim
                        
                        //50
                        idDizisi.append(id)
                    }
                    
                }
                //51 yeniliyoruz
                tableView.reloadData()
                
            }
            
        } catch {
            print("error")
        }
        
    }
    
    //39
    @objc func plusclicked() {
        //56 performsegue oncesinde secilen yer ismini bos olarak yollayalimki maps tarafinda secilen yer ismi bos gelsin if else calissin. yeni veri ekleme olsun
        selectedPlacename = ""
        
        //39
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    
    //36
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameDizisi.count
    }
   //37
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameDizisi[indexPath.row]
        return cell
    }
    
    //54
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //57 secilen seyleri atayalim
        selectedPlacename = nameDizisi[indexPath.row]
        selectedplaceid = idDizisi[indexPath.row]
        
        
        
        //54
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //58
        if segue.identifier == "toMapsVC" {
            //gidecegimiz hedef VC
            let destinationVC = segue.destination as!MapsViewController
            //59 veri aktarimini gerceklestirmis olduk
            destinationVC.selectedname = selectedPlacename
            destinationVC.selectedid = selectedplaceid
        }
    }

}
