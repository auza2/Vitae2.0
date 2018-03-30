//
//  individualWorkout.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/28/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData

class individualWorkout: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    
    var workout: Workout!
    var dummyWorkoutName: String!
    var dummyExercises = [Exercise]()
    var variants = [[Variant]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        
        container = appDelegate.persistentContainer

        navigationItem.title = dummyWorkoutName
        loadDummyWorkout()
        loadSavedData()
    }
    
    
    func loadDummyWorkout(){
        // Loading Dummy Workout
        let workReq = Workout.createFetchRequest()
        let workSort = NSSortDescriptor(key: "name", ascending: true)
        workReq.predicate = NSPredicate(format: "name == %@", dummyWorkoutName)
        workReq.sortDescriptors = [workSort]
        
        do{
            let workouts = try container.viewContext.fetch(workReq)
            workout = workouts[0]
            tableView.reloadData()
            print("found workouts \(workout.name)")
        }catch{
            print("Was not able to load Saved Data -- workouts")
        }
    }
    
    func loadSavedData(){
        let req = Exercise.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        req.predicate = NSPredicate(format: "SUBQUERY(workouts, $x, $x.name == %@).@count == 1", dummyWorkoutName)
        req.sortDescriptors = [sort]
        
        
        do{
            dummyExercises = try container.viewContext.fetch(req)
            tableView.reloadData()
            print("found \(dummyExercises.count) exercises")
        }catch{
            print("Was not able to load Saved Data")
        }
        
        variants.removeAll()
        for (_,exercise) in dummyExercises.enumerated(){
            print("Getting variants for \(exercise.name)")
            let variantsForExercise = loadVariants(for: exercise)
            variants.append(variantsForExercise)
            print("size of variants for the exercise: \(variantsForExercise.count)")
        }
    }
    
    func loadVariants(for exercise:Exercise) -> [Variant]{
        let req = Variant.createFetchRequest()
        let sort = NSSortDescriptor(key: "weight", ascending: false)
        req.sortDescriptors = [sort]
        req.predicate = NSPredicate(format: "exercise.name == %@", exercise.name)
        
        do{
            let variantsForExercise = try container.viewContext.fetch(req)
            return variantsForExercise
        }catch{
            print("Could not fetch variants for exercise \(exercise.name)")
        }
        return [Variant]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dummyExercises.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dummyExercises[section].variants?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "variationCell", for: indexPath) as? variationCell else {return UITableViewCell()}
        
        cell.variationLabel?.text = "\(variants[indexPath.section][(indexPath.row)].sets) X \(variants[indexPath.section][(indexPath.row)].repetitions) \(variants[indexPath.section][(indexPath.row)].weight)lb"
        
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
    
    
    // Mark-- Table View header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as? sectionHeader else {return UIView()}
        if isEditing{
            headerView.addButton.addTarget(self, action: #selector(addButton(sender:)), for: .touchUpInside)
        }else{
            headerView.addButton.removeFromSuperview()
        }
        headerView.headerTitle?.text = dummyExercises[section].name.uppercased()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
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
        print("buttonTapped")
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditing = !isEditing
        tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
