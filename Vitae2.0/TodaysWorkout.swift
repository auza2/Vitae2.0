//
//  TodaysWorkout.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/27/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData

class sectionHeader: UITableViewCell{
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
}

class variationCell: UITableViewCell{
    @IBOutlet weak var variationLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
}

class TodaysWorkout: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    
    var todaysLog: Log!
    var exercises = [Exercise]()
    var variants = [[Variant]]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        container = appDelegate.persistentContainer
        setUpLog()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Core Data
    func setUpLog(){
        // If there is no log currently with today's date then create one if there is then set it to today's Log
        let req = Log.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)

        let startDate = Date().getStartOfDay()
        let endDate = Date().getEndOfDay()
        req.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate,endDate)
        req.sortDescriptors = [sort]
        
        do{
            let logs = try container.viewContext.fetch(req)
            if logs.count >= 1{
                todaysLog = logs[0]
                print("found \(logs.count) logs for today // If more than one something went wrong")
                loadSavedData()
                tableView.reloadData()
            }else{
                todaysLog = Log(context: container.viewContext)
                todaysLog.date = Date()
                print("created new log for today")
                appDelegate.saveContext()
            }
        }catch{
            print("Was not able to load Saved Data")
        }
    }
    
    func loadSavedData(){
        let req = Variant.createFetchRequest()
        let sort = NSSortDescriptor(key: "weight", ascending: true)
        req.sortDescriptors = [sort]
        req.predicate = NSPredicate(format: "SUBQUERY(logs, $x, $x.date >= %@ AND $x.date <= %@).@count == 1", todaysLog.date.getStartOfDay(), todaysLog.date.getEndOfDay())

        var allVariantsForToday: [Variant]!
        do{
            allVariantsForToday = try container.viewContext.fetch(req)
            print("found \(variants.count) variants for \(todaysLog.date)")
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
            
            variants[variants.count-1].append(variant)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - Button taps
    @objc func buttonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !isEditing{
            if sender.isSelected{
                sender.setImage(#imageLiteral(resourceName: "icons8-tick-box-50"), for: .normal)
            }else{
                sender.setImage(#imageLiteral(resourceName: "icons8-unchecked-checkbox-50"), for: .normal)
            }
        }
    }
    
    @objc func addButton(sender: UIButton!){
        print("buttonTapped")
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditing = !isEditing
        tableView.reloadData()
    }

    @IBAction func save(_ sender: Any) {
    }
   
    // MARK: - Adding, Deleting, Editing Model
    @IBAction func openWorkoutLibrary(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ExerciseLibrary") as? UITabBarController{
            
            if let viewControllers = vc.viewControllers{
                if let exercisesVC = viewControllers[0] as? Exercises{
                    exercisesVC.todaysWorkoutDelegate = self
                }
                if let workoutVC = viewControllers[1] as? Workouts{
                    workoutVC.todaysWorkoutDelegate = self
                }
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addVariantToToday(_ variant: Variant){
        todaysLog.addToVariants(variant)
        appDelegate.saveContext()
        loadSavedData()
        tableView.reloadData()
    }

    @objc func deleteThisVariation(sender: UIButton){
        print("remove this variant from todays log")
        if let cell = sender.superview?.superview as? variationCell {
            let indexPath = tableView.indexPath(for: cell)!
            let variantToRemoveDate = variants[indexPath.section][indexPath.row]
            variantToRemoveDate.removeFromLogs(todaysLog)
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
}

extension Date{
    func getStartOfDay() -> NSDate{
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self )
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        return startDate! as NSDate
    }
    
    func getEndOfDay() -> NSDate{
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self )
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        return endDate! as NSDate
    }

}
