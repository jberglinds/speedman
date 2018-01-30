//
//  EventsTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

  // MARK: Properties
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier: "sv_SE")
    return dateFormatter
  }()
  private var events = [Event]()

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Events"

    API.getEvents() { result in
      switch result {
      case .success(let events):
        self.events = events
        self.tableView.reloadData()
      case .failure(let error):
        print(error)
      }
    }
  }

  // MARK: Actions
  @IBAction func logout(_ sender: UIBarButtonItem) {
    API.logout()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let logInCtrl = storyboard.instantiateViewController(withIdentifier: "login")
    self.present(logInCtrl, animated: true) {}
  }

  // MARK: - UITableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return events.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell",
                                             for: indexPath)

    let event = events[indexPath.row]
    if let eventsCell = cell as? EventTableViewCell {
      eventsCell.nameLabel.text = event.companyName
      eventsCell.dateLabel.text = "Today"
      eventsCell.locationLabel.text = event.location
    }
    return cell
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

  // MARK: - Navigation
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "eventDetailSegue", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "eventDetailSegue" else {
      return
    }

    if let selectedCell = tableView.indexPathForSelectedRow {
      if let eventsVC = segue.destination as? EventDetailViewController {
        eventsVC.event = events[selectedCell.row]
      }
    }
  }

}
