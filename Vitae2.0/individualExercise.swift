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
    
    weak var todaysWorkoutDelegate: TodaysWorkout?
    weak var individualWorkoutDelegate: individualWorkout?
    
    var isMultiAdding = false{
        didSet{
            navigationItem.rightBarButtonItem?.isEnabled = !isMultiAdding
        }
    }
    var numAdding: Int = 0{
        didSet{
            let buttonLabel = (numAdding > 0 ) ? "Add" : "Multi Add"
            multiAddButton.setTitle(buttonLabel, for: .normal)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var multiAddButton: UIButton!
    
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
        
        if isMultiAdding{
            UIView.animate(withDuration: 0.5, animations: {
                cell.checkButton.frame.origin.x = 20
            })
            
            let image = (cell.checkButton.isSelected) ? #imageLiteral(resourceName: "icons8-checked-50") : #imageLiteral(resourceName: "icons8-full-moon-50")
            cell.checkButton.setImage(image, for: .normal)
            cell.checkButton.addTarget(self, action: #selector(mulitSelect(sender:)), for: .touchUpInside)
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                cell.checkButton.frame.origin.x = -cell.checkButton.frame.width
            })
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as? sectionHeader else {return UIView()}
        headerView.addButton.removeFromSuperview() // the ability to add is already in the navigation view
        headerView.headerTitle?.text = dummyExerciseName
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMultiAdding { return }
        returnVariantsToAdd([variants[indexPath.row]])
    }
    
    // MARK: - Button taps
    @objc func mulitSelect(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        numAdding = sender.isSelected ? numAdding + 1 : numAdding - 1
        let image = sender.isSelected ? #imageLiteral(resourceName: "icons8-checked-50") : #imageLiteral(resourceName: "icons8-full-moon-50")
        sender.setImage(image, for: .normal)
    }
    
    @IBAction func mutliAdd(_ sender: Any) {
        if let button = sender as? UIButton{
            if button.titleLabel?.text == "Add"{
                // look through and add then return
                var variationsToAdd = [Variant]()
                for cell in tableView.visibleCells{
                    if let varCell = cell as? variationCell, varCell.checkButton.isSelected == true{
                        let indexPath = tableView.indexPath(for: cell)!
                        variationsToAdd.append(variants[indexPath.row])
                    }
                }
                returnVariantsToAdd(variationsToAdd)
            }else{
                isMultiAdding = !isMultiAdding
                button.isSelected = !button.isSelected
                button.layer.backgroundColor = button.isSelected ? button.tintColor.cgColor : UIColor.clear.cgColor
                tableView.reloadData()
            }
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


    // MARK: - Returning Variants Selected
    func returnVariantsToAdd(_ variantsToAdd:[Variant]){
        if let todaysWorkout = todaysWorkoutDelegate{
            todaysWorkout.addVariantToToday(variantsToAdd)
            navigationController?.popToViewController(todaysWorkout, animated: true)
        }
        if let individualWorkout = individualWorkoutDelegate{
            individualWorkout.addVariantToWorkout(variantsToAdd)
            navigationController?.popToViewController(individualWorkout, animated: true)
        }
    }
}
