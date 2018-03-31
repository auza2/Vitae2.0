//
//  ViewController.swift
//  exerciseLibrary_HwS
//
//  Created by Jamie Auza on 3/7/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData
class ExerciseCell: UITableViewCell{
    weak var tableviewCellDelegate: tableViewCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
//    @IBAction func moreOptions(_ sender: Any) {
//        tableviewCellDelegate?.moreOptions(self)
//    }
}

protocol tableViewCellDelegate : class {
    func moreOptions(_ sender: ExerciseCell) // To do will show data
}

class Exercises: UITableViewController, tableViewCellDelegate {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    var workout: Workout?
    var exercises = [Exercise]()
    var indexOfExerciseAdd: IndexPath?
    
    weak var todaysWorkoutDelegate: TodaysWorkout?
    weak var individualWorkoutDelegate: individualWorkout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = appDelegate.persistentContainer
        loadSavedData()
        
        if let detailWorkout = workout{
            navigationItem.title = detailWorkout.name
        }
    }
    
    // MARK -- Core Data
    
    func loadSavedData(){
        let req = Exercise.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        req.sortDescriptors = [sort]
        
        if let detailWorkout = workout{
            req.predicate = NSPredicate(format: "SUBQUERY(workouts, $x, $x.name == %@).@count == 1", detailWorkout.name)
        }
        
        do{
            exercises = try container.viewContext.fetch(req)
            tableView.reloadData()
            print("found \(exercises.count) exercises")
        }catch{
            print("Was not able to load Saved Data")
        }
    }

    @IBAction func add(_ sender: Any) {
        let ac = UIAlertController(title: "Create new exercise", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Name"
        })
        ac.addAction(UIAlertAction(title: "Done", style: .default, handler: { [unowned self] _ in
            let exercise = Exercise(context: self.container.viewContext)
            exercise.name = ac.textFields?[0].text ?? " "
            self.appDelegate.saveContext()
            self.loadSavedData()
            }))
        
        present(ac,animated: true)
    }
    
    // MARK -- TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        
        if let exerciseCell = cell as? ExerciseCell{
            exerciseCell.titleLabel.text = exercises[indexPath.row].name
            exerciseCell.tableviewCellDelegate = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "individualExercise") as? individualExercise{
            vc.dummyExerciseName = exercises[indexPath.row].name
            vc.todaysWorkoutDelegate = todaysWorkoutDelegate
            vc.individualWorkoutDelegate = individualWorkoutDelegate
            vc.exercise = exercises[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK -- TableViewCell Delegate
    func moreOptions(_ sender: ExerciseCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        indexOfExerciseAdd = indexPath
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "workoutsView") as? WorkoutsViewController{
//            vc.navigationItem.title = "Choose Workout"
//            vc.exercise = exercises[indexPath.row]
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
//    func addExerciseTo(_ workout:Workout){
//        let req = Workout.createFetchRequest()
//        let descriptor = NSSortDescriptor(key: "name", ascending: true)
//        req.sortDescriptors = [descriptor]
//        req.predicate = NSPredicate(format: "name == %@", workout.name)
//
//        do{
//            let fetchedWorkouts = try container.viewContext.fetch(req)
//            if let indexPath = indexOfExerciseAdd{
//                fetchedWorkouts[0].addToExercises(exercises[indexPath.row])
//
//                appDelegate.saveContext()
//                loadSavedData()
//                indexOfExerciseAdd = nil
//            }
//        }catch{
//            print("\(error)")
//        }
//    }
    
    // MARK -- Adding, Deleting, Editing Model
    func returnExercise(_ variant: Variant){
        todaysWorkoutDelegate?.addVariantToToday(variant)
        individualWorkoutDelegate?.addVariantToWorkout(variant)
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

