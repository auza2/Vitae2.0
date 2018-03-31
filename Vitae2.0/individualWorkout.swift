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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = workout else {return}

        container = appDelegate.persistentContainer
        
//        let exercise = Exercise(context: container.viewContext)
//        exercise.name = "Dummy Exercise 2"
//        let variant = Variant(context: container.viewContext)
//        variant.sets = 12345
//        variant.repetitions = 12345
//        variant.weight = 12345
//        variant.exercise = exercise
//        workout.addToVariants(variant)
//        appDelegate.saveContext()
        

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
            }

            print("\(exerciseForThisVariant.name) | \(variant.sets) ,\(variant.repetitions), \(variant.weight) ")
            variants[variants.count-1].append(variant)
        }
        print("-------------")
        
    }
//    func loadSavedData(){
//        let req = Exercise.createFetchRequest()
//        let sort = NSSortDescriptor(key: "name", ascending: true)
//        req.predicate = NSPredicate(format: "SUBQUERY(workouts, $x, $x.name == %@).@count == 1", workout.name)
//        req.sortDescriptors = [sort]
//
//        do{
//            exercises = try container.viewContext.fetch(req)
//            tableView.reloadData()
//            print("found \(exercises.count) exercises")
//        }catch{
//            print("Was not able to load Saved Data")
//        }
//
//        variants.removeAll()
////        for (_,exercise) in exercises.enumerated(){
////            print("Getting variants for \(exercise.name)")
////            let variantsForExercise = loadVariants(for: exercise)
////            variants.append(variantsForExercise)
////            print("size of variants for the exercise: \(variantsForExercise.count)")
////        }
//        for (_,exercise) in exercises.enumerated(){
//            print("Getting variants for \(exercise.name)")
//            let variantsForExercise = exercise.value(forKeyPath: "variants") as? [Variant] ?? [Variant]()
//            variants.append(variantsForExercise)
//            print("size of variants for the exercise: \(variantsForExercise.count)")
//        }
//    }
    
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
            cell.checkButton.setImage(#imageLiteral(resourceName: "icons8-cancel-50"), for: .normal)
            cell.checkButton.addTarget(self, action: #selector(deleteThisVariation(sender:)), for: .touchUpInside)
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
        headerView.headerTitle?.text = exercises[section].name.uppercased()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let todaysWorkout = todaysWorkoutDelegate{
            todaysWorkout.addVariantToToday(variants[indexPath.section][indexPath.row])
            navigationController?.popToViewController(todaysWorkout, animated: true)
        }
        if let individualWorkout = individualWorkoutDelegate{
            individualWorkout.addVariantToWorkout(variants[indexPath.section][indexPath.row])
            navigationController?.popToViewController(individualWorkout, animated: true)
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
        print("buttonTapped")
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
    
    // MARK: - Adding, Deleting, Editing Model
    func addVariantToWorkout(_ variant: Variant){
        workout.addToVariants(variant) //because we're using the same container this should work at creating a relationship
        appDelegate.saveContext()
        loadSavedData()
        tableView.reloadData()
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
        tableView.reloadData()
    }

}
