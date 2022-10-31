//
//  ViewController.swift
//  ListAppUI
//
//  Created by Vural Kayra Çetintaş on 30.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    

    var alertController = UIAlertController()
    var data = [NSManagedObject]()
    

    @IBOutlet weak var myTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        fetch()
      
    }
    
    //coreData remove allItem entity
    @IBAction func didRemoveBarButtonItemTapped (_ sebder: UIBarButtonItem){
        
        presentAlert(title: "Warning !", message: "Are you sure you want to delete",defaultButtonTitle: "Yes", cancelButtonTitle: "Cancel") { _ in
            let appDelete = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelete?.persistentContainer.viewContext
            for item in self.data{
                managedObjectContext?.delete(item)
            }
            try? managedObjectContext?.save()
            self.fetch()
            
           
        }
    }
    @IBAction func didAddBarButtonItemTapped (_ sender : UIBarButtonItem){
       
        self.presentAddAlert()
        
    }
    
 
    func presentAddAlert(){
        presentAlert(title: "Add New Item",
                     message: nil,
                     defaultButtonTitle: "Add",
                     cancelButtonTitle: "Cancel",
                     isTextFİledAvailable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
              //  self.data.append((text)!)
                let appDelete = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelete?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listeItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listeItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                    self.fetch()
            }  else {
                self.presentWarningAlert()
            }
        })
    }
    
    func presentWarningAlert(){
        
        presentAlert(title: "Warning", message: "List Cannot Be Empty", cancelButtonTitle: "Okey")
    }
    
    func presentAlert(title: String? ,
                      message: String? ,
                      preferredStyle : UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFİledAvailable: Bool = false,
                      defaultButtonHandler : ((UIAlertAction) -> Void)? = nil){
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default,handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFİledAvailable{
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate  as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        myTableView.reloadData()
    }
    
}



extension ViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
            
            
            let appDelegate = UIApplication.shared.delegate  as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            self.fetch()
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") {_, _, _ in
            self.presentAlert(title: "Edit Element",
                         message: nil,
                         defaultButtonTitle: "Edit",
                         cancelButtonTitle: "Cancel",
                         isTextFİledAvailable: true,
                         defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    
                    let appDelegate = UIApplication.shared.delegate  as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                   
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    self.myTableView.reloadData()
                }  else {
                    self.presentWarningAlert()
                }
            })}
        editAction.backgroundColor = .systemGreen
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction ,editAction])
        return config
    }
}
