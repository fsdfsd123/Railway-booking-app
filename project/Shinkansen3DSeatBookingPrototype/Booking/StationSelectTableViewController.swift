////
////  StationSelectTableViewController.swift
////  Shinkansen3DSeatBookingPrototype
////
////  Created by shawn on 2019/12/12.
////  Copyright © 2019 Virakri Jinangkul. All rights reserved.
////
//
//import UIKit
//
//class StationSelectTableViewController: UITableViewController {
//
//
//    var station = [
//        "臺北市","新北市","桃園市","臺中市","臺南市","高雄市",
//    "基隆市",
//        "新竹市",
//        "嘉義市"
//
//    ]
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StationCell")
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return station.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as! StationCell
//        //let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! StationCell
//        cell.textLabel?.text = station[indexPath.row]
//        // Configure the cell...
//
//        return cell
//    }
//
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
import UIKit
class StationSelectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var type = 0 
    var tableView = UITableView()
    //var tableData = ["Beach", "Clubs", "Chill", "Dance"]
        var tableData = [
            "臺北市","新北市","桃園市","臺中市","臺南市","高雄市",
        "基隆市",
            "新竹市",
            "嘉義市"
    
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.backgroundColor = UIColor.white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "my")
        
        tableView.contentInset.top = 20
        let contentSize = self.tableView.contentSize
        let footer = UIView(frame: CGRect(x: self.tableView.frame.origin.x,
                                          y: self.tableView.frame.origin.y + contentSize.height,
                                          width: self.tableView.frame.size.width,
                                          height: self.tableView.frame.height - self.tableView.contentSize.height))
        
        self.tableView.tableFooterView = footer
        self.tableView.backgroundColor = .black
        //self.tableView.setupTheme()
        
        view.addSubview(tableView)
        print("type=-------\(type)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath)
        cell.textLabel?.text = " \(tableData[indexPath.row])"
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }


//    var fromStation = ""
//    var destinationStation = ""
    var mainvc: BookingCriteriaViewController?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(type==0){
            print(tableData[indexPath.row])
            
            mainvc?.fromStation = tableData[indexPath.row]
            mainvc?.fromStationCardControl.setupValue(stationNameJP: tableData[indexPath.row], stationName: tableData[indexPath.row])
            
            
        }
        else{
            mainvc?.destinationStation = tableData[indexPath.row]
            mainvc?.destinationStationCardControl.setupValue(stationNameJP: tableData[indexPath.row], stationName: tableData[indexPath.row])
        }
    
        dismiss(animated: true, completion: nil)
    }
}
