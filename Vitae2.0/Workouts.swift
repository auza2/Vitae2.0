//
//  WorkoutsViewController.swift
//  exerciseLibrary_HwS
//
//  Created by Jamie Auza on 3/13/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData

class Workouts: UITableViewController {
     var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    var workouts = [Workout]()
    weak var delegate: Exercises?
    weak var exercise: Exercise?
    
    weak var todaysWorkoutDelegate: TodaysWorkout?
    weak var individualWorkoutDelegate: individualWorkout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container = appDelegate.persistentContainer
        loadSavedData()
    }
    
    func loadSavedData(){
        let req = Workout.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        req.sortDescriptors = [sort]
        
        do{
            workouts = try container.viewContext.fetch(req)
            tableView.reloadData()
            print("found \(workouts.count) workouts")
        }catch{
            print("Was not able to load Saved Data -- workouts")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addWorkout(_ sender: Any) {
        let ac = UIAlertController(title: "Name new workout", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "save", style: .default, handler: {
            [unowned self] _  in
                let workout = Workout(context: self.container.viewContext)
                workout.name = ac.textFields?[0].text! ?? " "
            
                self.appDelegate.saveContext()
                self.loadSavedData()
            }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac,animated: true)
    }
    
    func returnExercise(_ variant: Variant){
        if let todayVC = todaysWorkoutDelegate{
            todayVC.addVariantToToday([variant])
        }
        individualWorkoutDelegate?.addVariantToWorkout([variant])
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)

        cell.textLabel?.text = workouts[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "individualWorkout") as? individualWorkout{
            vc.workout = workouts[indexPath.row]
            vc.todaysWorkoutDelegate = todaysWorkoutDelegate
            vc.individualWorkoutDelegate = individualWorkoutDelegate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
