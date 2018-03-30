//
//  individualExercise.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/28/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData

class individualExercise: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    
    var dummyExerciseName: String!
    var exercise: Exercise!
    var variants: [Variant]!
    var delegate: Exercises?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        container = appDelegate.persistentContainer
        
        navigationItem.title = dummyExerciseName
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButton(sender:)))
        loadSavedData()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Core Data
    
    func loadSavedData(){
        let req = Variant.createFetchRequest()
        let sort = NSSortDescriptor(key: "weight", ascending: true)
        req.predicate = NSPredicate(format: "exercise.name == %@", dummyExerciseName)
        req.sortDescriptors = [sort]

        do{
            variants = try container.viewContext.fetch(req)
            tableView.reloadData()
            print("found \(variants.count) variants")
        }catch{
            print("Was not able to load Saved Data")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return variants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "variationCell", for: indexPath) as? variationCell else {return UITableViewCell()}
        
         cell.variationLabel?.text = "Weight: \(variants[indexPath.row].weight) | Set: \(variants[indexPath.row].sets) | Rep: \(variants[indexPath.row].repetitions)"
        
        if isEditing{
            cell.checkButton.setImage(#imageLiteral(resourceName: "icons8-cancel-50"), for: .normal)
            cell.checkButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        }else{
            let image = (cell.checkButton.isSelected) ? #imageLiteral(resourceName: "icons8-tick-box-50") : #imageLiteral(resourceName: "icons8-unchecked-checkbox-50")
            cell.checkButton.setImage(image, for: .normal)
            cell.checkButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as? sectionHeader else {return UIView()}
        if isEditing{
            headerView.addButton.addTarget(self, action: #selector(addButton(sender:)), for: .touchUpInside)
        }else{
            headerView.addButton.removeFromSuperview()
        }
        headerView.headerTitle?.text = dummyExerciseName
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ExercisesVC = delegate{
            if variants[indexPath.row].datesLogged == nil{
                variants[indexPath.row].datesLogged = [Date]()
            }
            variants[indexPath.row].datesLogged?.append(Date())
            appDelegate.saveContext()
            
            ExercisesVC.returnExercise(exercise)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Button taps
    @objc func buttonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            sender.setImage(#imageLiteral(resourceName: "icons8-tick-box-50"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "icons8-unchecked-checkbox-50"), for: .normal)
        }
    }
    
    @objc func addButton(sender: UIButton!){
        let ac = UIAlertController(title: "Create new exercise", message: "Fill information below", preferredStyle: .alert)
        
        // Text Fields
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Sets"
        })
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Repetions"
        })
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Weight"
        })
        
        //Save + Cancel
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            [unowned self] action in
            guard let sets = ac.textFields?[0], let reps = ac.textFields?[1], let weight = ac.textFields?[2] else {return}
            
            let setNum = Int16(sets.text!) ?? 0
            let repNum = Int16(reps.text!) ?? 0
            let weightNum = Int16(weight.text!) ?? 0
            
            let newVariant = Variant(context:  self.container.viewContext)
            newVariant.sets = setNum
            newVariant.repetitions = repNum
            newVariant.weight = weightNum
            
            self.exercise.addToVariants(newVariant)
            self.appDelegate.saveContext()
            self.loadSavedData()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present( ac, animated: true)
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditing = !isEditing
        tableView.reloadData()
    }

}
