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
    var exercises = [Exercise]()
    var variants = [[Variant]]()
    
    weak var todaysWorkoutDelegate: TodaysWorkout?
    weak var individualWorkoutDelegate: individualWorkout?
    
    var isMultiAdding:Bool = false{
        didSet{
            editButton.isEnabled = !isMultiAdding
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
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = workout else {return}

        container = appDelegate.persistentContainer
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        navigationItem.title = workout.name
        loadSavedData()
    }
    
    // MARK: Core Data
    func loadSavedData(){
        let req = Variant.createFetchRequest()
        let sort = NSSortDescriptor(key: "weight", ascending: true)
        req.sortDescriptors = [sort]
        req.predicate = NSPredicate(format: "SUBQUERY(workouts, $x, $x.name == %@ ).@count == 1", workout.name)

        print("getting all variants for workout \(workout.name)")
        var allVariantsForToday: [Variant]!
        do{
            allVariantsForToday = try container.viewContext.fetch(req)
            print("found \(allVariantsForToday.count) variants for \(workout.name)")
        }catch{
            print("Was not able to load Saved Data")
        }

        variants.removeAll()
        exercises.removeAll()

        // Going through all the variants that are logged for today, find the exercises that it belongs to and
        // give it to the variants and exercises array for easier display in table view
        var exerciseIndex = 0
        for (_,variant) in allVariantsForToday.enumerated(){
            let exerciseForThisVariant = variant.value(forKey: "exercise") as! Exercise
            print(exerciseForThisVariant.name)

            let exercisesHasExerciseAlready = exercises.contains{ exerciseInExercises in
                return exerciseInExercises.name == exerciseForThisVariant.name
            }
            
            if !exercisesHasExerciseAlready{
                variants.append([Variant]())
                exercises.append(exerciseForThisVariant)
                exerciseIndex += 1
                variants[variants.count-1].append(variant)
            }else{
                let indexOfExercise = exercises.index(of: exerciseForThisVariant) ?? variants.count-1
                variants[indexOfExercise].append(variant)
            }
        }
        print("-------------")
        
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
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return variants[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "variationCell", for: indexPath) as? variationCell else {return UITableViewCell()}
        
        cell.variationLabel?.text = "\(variants[indexPath.section][(indexPath.row)].sets) X \(variants[indexPath.section][(indexPath.row)].repetitions) \(variants[indexPath.section][(indexPath.row)].weight)lb"
        
        if isEditing{
            UIView.animate(withDuration: 0.5, animations: {
                cell.checkButton.frame.origin.x = 20
            })
            cell.checkButton.setImage(#imageLiteral(resourceName: "icons8-cancel-50"), for: .normal)
            cell.checkButton.removeTarget(nil, action: nil, for: .allEvents)
            cell.checkButton.addTarget(self, action: #selector(deleteThisVariation(sender:)), for: .touchUpInside)
        }else if isMultiAdding{
            UIView.animate(withDuration: 0.5, animations: {
                cell.checkButton.frame.origin.x = 20
            })
            
            let image = (cell.checkButton.isSelected) ? #imageLiteral(resourceName: "icons8-checked-50") : #imageLiteral(resourceName: "icons8-full-moon-50")
            cell.checkButton.setImage(image, for: .normal)
            cell.checkButton.removeTarget(nil, action: nil, for: .allEvents)
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
        headerView.headerTitle?.text = exercises[section].name.uppercased()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let todaysWorkout = todaysWorkoutDelegate{
            todaysWorkout.addVariantToToday([variants[indexPath.section][indexPath.row]])
            navigationController?.popToViewController(todaysWorkout, animated: true)
        }
        if let individualWorkout = individualWorkoutDelegate{
            individualWorkout.addVariantToWorkout([variants[indexPath.section][indexPath.row]])
            navigationController?.popToViewController(individualWorkout, animated: true)
        }
    }
    
    // MARK: - Button taps
    @objc func mulitSelect(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        numAdding = sender.isSelected ? numAdding + 1 : numAdding - 1
        let image = sender.isSelected ? #imageLiteral(resourceName: "icons8-checked-50") : #imageLiteral(resourceName: "icons8-full-moon-50")
        sender.setImage(image, for: .normal)
    }
    
    
    @IBAction func openWorkoutLibrary(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseLibrary") as? UITabBarController{
            
            if let viewControllers = vc.viewControllers{
                if let exercisesVC = viewControllers[0] as? Exercises{
                    exercisesVC.individualWorkoutDelegate = self
                }
                if let workoutVC = viewControllers[1] as? Workouts{
                    workoutVC.individualWorkoutDelegate = self
                }
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func multiAdd(_ sender: Any) {
        if let button = sender as? UIButton{
            if button.titleLabel?.text == "Add"{
                // look through and add then return
                var variationsToAdd = [Variant]()
                for cell in tableView.visibleCells{
                    if let varCell = cell as? variationCell, varCell.checkButton.isSelected == true{
                        let indexPath = tableView.indexPath(for: cell)!
                        variationsToAdd.append(variants[indexPath.section][indexPath.row])
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
    
    // MARK: - Adding, Deleting, Editing Model
    func addVariantToWorkout(_ variantsToAdd: [Variant]){
        for eachVariant in variantsToAdd{
            workout.addToVariants(eachVariant) // For some reason I cannot use "func addToVariants(_ values: [Variant])" to insert a whole array
        }
        appDelegate.saveContext()
        loadSavedData()
        tableView.reloadData()
    }
    
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
    
    @objc func deleteThisVariation(sender: UIButton){
        print("remove this variant from this \(workout.name)")
        if let cell = sender.superview?.superview as? variationCell {
            let indexPath = tableView.indexPath(for: cell)!
            let variantToRemove = variants[indexPath.section][indexPath.row]
            variantToRemove.removeFromWorkouts(workout)
            appDelegate.saveContext()
            
            let prevNumSection = variants.count
            loadSavedData()
            
            if (prevNumSection > variants.count){
                tableView.deleteSections([indexPath.section], with: .automatic)
            }else{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
           tableView.reloadData()
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditing = !isEditing
        multiAddButton.isEnabled = !isEditing
        tableView.reloadData()
    }

}
