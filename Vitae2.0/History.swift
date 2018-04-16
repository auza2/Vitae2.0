//
//  History.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 4/1/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit
import CoreData

class History: UITableViewController, graphViewDataSource {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer!
    
    @IBOutlet weak var graphView: GraphView!
    weak var exercise: Exercise!
    var maxWeight = -1
    
    var variants = [[Variant]]()
    var logs = [Log]()
    var sortByOption = History.sort.Oldest{
        didSet{
            loadSavedData()
            tableView.reloadData()
        }
    }
    
    enum sort{
        case Newest
        case Oldest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = exercise else { return }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonIteM
        
        navigationItem.title = exercise.name
        print(exercise.name)
        container = appDelegate.persistentContainer
        
        
        loadSavedData()
        graphView.delegate = self
    }
    
    // MARK: -- Core Data
    func loadSavedData(){
        let req = Variant.createFetchRequest()
        let sort = NSSortDescriptor(key: "weight", ascending: false)
        req.sortDescriptors = [sort]
        req.predicate = NSPredicate(format: "exercise.name == %@", exercise.name)
        
        var allVariantsForExercise: [Variant]!
        do{
            allVariantsForExercise = try container.viewContext.fetch(req)
        }catch{
            print("unable to get variants")
        }
        
        variants.removeAll()
        logs.removeAll()
        
        // Going through all the variants for this exercise and going through each time it was logged
        // If there is no log
        print("----- History --- ")
        var indexToInsert = 0
        for (_,variant) in allVariantsForExercise.enumerated(){
            if maxWeight < variant.weight{
                maxWeight = Int(variant.weight)
            }
            let logsForThisVariant = getLogs(variant)
            
            for log in logsForThisVariant{
                if !logs.contains(log){
                    indexToInsert = binarySearch((sortByOption == .Newest), log.date, 0, logs.count-1)
                    print("Inserting \(log.date) to \(indexToInsert)")
                    print(logs)
                    
                    if( indexToInsert > logs.count-1 ){
                        logs.append(log)
                        variants.append([Variant]())
                    }else{
                        logs.insert(log, at: indexToInsert)
                        variants.insert([Variant](), at: indexToInsert)
                    }
                }else{
                    indexToInsert = logs.index(of: log)!
                }
                variants[indexToInsert].append(variant)
            }
        }
        print("----- History ----")
    }
    
    // Binary search to find the placement of this log and its variants
    func binarySearch(_ Newest:Bool, _ dateToInsert:Date,_ startIndex: Int,_ endIndex: Int) -> Int{
        if (logs.count == 0) {return 0}
        if (startIndex >= endIndex){
            if Newest{
                return (dateToInsert > logs[startIndex].date) ? startIndex : startIndex + 1
            }else{
                return (dateToInsert < logs[startIndex].date) ? startIndex : startIndex + 1
            }
        }
        
        let mid = (startIndex + endIndex) / 2
        let dateAtMid = logs[mid].date
        let predicate = Newest ? dateToInsert < dateAtMid : dateToInsert > dateAtMid
        
        if (predicate){
            return binarySearch(Newest,dateToInsert,mid+1,endIndex)
        }else{
            return binarySearch(Newest,dateToInsert,startIndex,mid)
        }
    }
    
    func getLogs(_ variant: Variant) -> [Log]{
        let req = Log.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)
        req.sortDescriptors = [sort]
        req.predicate = NSPredicate(format: "SUBQUERY(variants, $x, $x == %@).@count == 1", variant)
        
        var allLogs = [Log]()
        do{
            allLogs = try container.viewContext.fetch(req)
        }catch{
            print("unable to get variants")
        }
        return allLogs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Graph view data source
    func maxPointValue() -> Int{
        return maxWeight
    }
    
    func numberOfColumns(_ graphView: GraphView) -> Int {
        let start = startDate().getStartOfDay() as Date
        let end = endDate().getStartOfDay() as Date
        let numColums = Int( start.timeIntervalSince(end)/60/60/24 )
        let add = (numColums > 0) ? 1 : -1
        return numColums + add
    }
    
    func columnForPoint(_ graphView: GraphView, _ dataIndex:Int) -> Int {
        let dateForLog = logs[dataIndex].date.getStartOfDay() as Date
        let start = startDate().getStartOfDay() as Date
        let daysFromStart = Int(start.timeIntervalSince(dateForLog) / (60*60*24))
        
        return daysFromStart
    }
    
    func numberOfPoints(_ graphView: GraphView) -> Int {
       return logs.count
    }
    
    func valueForPoint(_ dataIndex:Int) -> Int {
        let variantsOfThisLog = variants[dataIndex]
        var maxValue = -1
        for variant in variantsOfThisLog{
            if (maxValue < variant.weight){
                maxValue = Int(variant.weight)
            }
        }
        return maxValue
    }
    
    func startDate() -> Date {
        return logs[0].date
    }
    
    func endDate() -> Date {
        return logs[logs.count-1].date
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return logs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return variants[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)

        cell.textLabel?.text = "\(variants[indexPath.section][(indexPath.row)].sets) X \(variants[indexPath.section][(indexPath.row)].repetitions) \(variants[indexPath.section][(indexPath.row)].weight)lb"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historySectionHeader") else {return UIView()}
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdYYYY")
        
        cell.textLabel?.text = "\(dateFormatter.string(from: logs[section].date))"
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    // MARK: -- button taps
    @IBAction func sortBy(_ sender: Any) {
        let ac = UIAlertController(title: "SORT HISTORY BY", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Newest", style: .default, handler: {
            [unowned self] action in
                self.sortByOption = .Newest
                // to do redraw the graph when this is done re ordering
            }))
        
        ac.addAction(UIAlertAction(title: "Oldest", style: .default, handler: {
            [unowned self] action in
                self.sortByOption = .Oldest
        }))
        
        present(ac, animated: true)
    }

}
