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
    var isPassenger: Bool?
    var myIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ispassenger: \(isPassenger) ++++++++++")
        if isPassenger == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPushed))
            //navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "editIcon"), style: .done, target: self, action: #selector(editPushed))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPushed))
            tableView.allowsSelection = true
        }
        else {
            tableView.allowsSelection = false
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.black
        
        let cellNib = UINib(nibName: "AnnouncementTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "MyAnnouncementCell")
        
        Database.database().reference().child("announcements").observe(.childAdded) { (snapshot) in
            print("eszrevette hogy child added")
            if (snapshot.value as? [String: AnyObject]) != nil {
                print(snapshot.value)
                //ha megkapta a snapshot-ot, azaz ez nem null, hozzatesszuk a listahoz
                self.announcements.append(Announcement(snapshot: snapshot))
                self.sortArray()
                /*for an in self.announcements {
                    print(an.writeMessage())
                }*/
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print(self.announcements.count)
            }
        }
        
        Database.database().reference().child("announcements").observe(.childRemoved) { (snapshot) in
            if (snapshot.value as? [String: AnyObject]) != nil {
                print("snapshot")
                print(snapshot)
                let deletedAnnouncement = Announcement(snapshot: snapshot)
                let index = self.announcements.index(where: {$0.key == deletedAnnouncement.key})
                print("******index: \(index)")
                if let index = index {
                    self.announcements.remove(at: index)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        Database.database().reference().child("announcements").observe(.childChanged) { (snapshot) in
            if (snapshot.value as? [String: AnyObject]) != nil {
                let updatedAnnouncement = Announcement(snapshot: snapshot)
                let index = self.announcements.index(where: {$0.key == updatedAnnouncement.key})
                if let index = index {
                    self.announcements.remove(at: index)
                    self.announcements.append(updatedAnnouncement)
                    self.sortArray()
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func editPushed() {
        print("edit volt emgnyomva")
        if myIndexPath != nil {
            performSegue(withIdentifier: "editFromAnnouncementsScreen", sender: self)
            //self.present(EditAnnouncementTableViewController(), animated: true, completion: nil)
        }
    }
    
    @objc func trashPushed() {
        print("trash volt emgnyomva")
        if let myIndexPath = myIndexPath {
            let announcementRef = Database.database().reference().child("announcements")
            announcementRef.child(announcements[myIndexPath.row].key).setValue(nil)
            
            announcements.remove(at: myIndexPath.row)
            
            let indexPaths = [myIndexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
            
            tableView.reloadData()
            self.myIndexPath = nil
        }
    }
    
    func sortArray() {
        self.announcements.sort { $0 < $1 }
        self.announcements.sort(by: { (ann1, ann2) -> Bool in
            if (ann1.important == ann2.important) {
                return ann1.timestamp > ann2.timestamp
            }
            return false
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("de emghivodott")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
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
        //print(announcements[indexPath.row].writeMessage())
        
        let date = NSDate(timeIntervalSinceReferenceDate: TimeInterval(announcements[indexPath.row].timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date as Date)
        
        cell.topImageView.isHidden = true
        cell.backgroundColor = UIColor.white
        cell.announcementTextView.backgroundColor = UIColor.white
        cell.titleLable.text = announcements[indexPath.row].title
        cell.announcementTextView.text = announcements[indexPath.row].message
        cell.timeLabel.text = dateString
        if announcements[indexPath.row].important == "true" {
            cell.topImageView.isHidden = false
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 221/255, green: 255/255, blue: 244/255, alpha: 0.5)
            cell.announcementTextView.backgroundColor = cell.backgroundColor
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myIndexPath = indexPath
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if isPassenger == nil, editingStyle == UITableViewCellEditingStyle.delete {
//            // handle delete (by removing the data from your array and updating the tableview)
//            let announcementRef = Database.database().reference().child("announcements")
//            announcementRef.child(announcements[indexPath.row].key).setValue(nil)
//
//            announcements.remove(at: indexPath.row)
//
//            let indexPaths = [indexPath]
//            tableView.deleteRows(at: indexPaths, with: .automatic)
//
//            tableView.reloadData()
//        }
    
    //}
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFromAnnouncementsScreen" {
            print("bejottem ahova kell \(#imageLiteral(resourceName: "travel"))")
            //let vc = EditAnnouncementTableViewController()
            if let myIndexPath = myIndexPath {
                let editAnnouncement = segue.destination as! EditAnnouncementTableViewController
                editAnnouncement.activeAnnouncement = announcements[myIndexPath.row]
            }
        }
    }
    
    deinit {
        print("az announcement bezarodott±±±±±±±±±±±±±±±±±±±±±±±")
    }

}

func < (lhs: Announcement, rhs: Announcement) -> Bool {
    return lhs.important.localizedStandardCompare(rhs.important) == .orderedDescending
}
