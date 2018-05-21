//
//  AnnouncementTableViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 14/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class AnnouncementTableViewController: UITableViewController {
    var announcements = [Announcement]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let cellNib = UINib(nibName: "AnnouncementTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "MyAnnouncementCell")
        
        Database.database().reference().child("announcements").observe(.childAdded) { (snapshot) in
            print("eszrevette hogy child added")
            if (snapshot.value as? [String: AnyObject]) != nil {
                print(snapshot.value)
                //ha megkapta a snapshot-ot, azaz ez nem null, hozzatesszuk a listahoz
                self.announcements.append(Announcement(snapshot: snapshot))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print(self.announcements.count)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAnnouncementCell", for: indexPath) as! AnnouncementTableViewCell
        print(announcements[indexPath.row].writeMessage())
        
        let date = NSDate(timeIntervalSinceReferenceDate: TimeInterval(announcements[indexPath.row].timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date as Date)
        
        cell.titleLable.text = announcements[indexPath.row].title
        cell.announcementTextView.text = announcements[indexPath.row].message
        cell.timeLabel.text = dateString

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

}
