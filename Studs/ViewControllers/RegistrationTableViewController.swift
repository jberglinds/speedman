//
//  RegistrationTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-06.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Tableviewcontroller for registering people to a trip activity

import UIKit

class RegistrationTableViewController: UITableViewController {
  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private lazy var activity: TripActivity! = self.store.state.selectedActivity
  private var users = [User]() {
    didSet { tableView.reloadData() }
  }
  private var registrations = [TripActivityRegistration]() {
    didSet { tableView.reloadData() }
  }
  private let haptic = UISelectionFeedbackGenerator()
  private var registrationSubscription: Subscription<[TripActivityRegistration]>?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if let activity = activity {
      navigationItem.prompt = activity.title
      registrationSubscription =
        Firebase.streamActivityRegistrations(activityId: activity.id) { [weak self] in
        self?.registrations = $0
      }
    } else {
      dismiss(animated: true)
    }
    // Setup swipe down to refresh action
    refreshControl?.addTarget(self, action: #selector(fetchUsers),
                              for: .valueChanged)
  }

  deinit {
    registrationSubscription?.unsubscribe()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tableView.triggerRefresh()
  }

  @objc func fetchUsers() {
    API.getUsers { result in
      switch result {
      case .success(let users):
        self.users = users.sorted { user1, user2 in
          user1.fullName < user2.fullName
        }
      case .failure(let error):
        self.dismiss(animated: true)
        print(error)
      }
      self.refreshControl?.endRefreshing()
    }
  }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true)
  }
}

// MARK: UITableViewDataSource
extension RegistrationTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
      let user = users[indexPath.row]
      cell.accessoryType = registrations.contains { user.id == $0.userId }
        ? .checkmark
        : .none
      cell.textLabel?.text = user.fullName
      return cell
  }
}

// MARK: UITableViewDelegate
extension RegistrationTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let user = users[indexPath.row]
    guard let actingUser = UserManager.shared.user else { return }
    if let registration = registrations.first(where: { user.id == $0.userId }) {
      Firebase.removeActivityRegistration(registrationId: registration.id,
                                          activityId: activity.id)
    } else {
      Firebase.addActivityRegistration(userId: user.id,
                                       byUserId: actingUser.id,
                                       activityId: activity.id)
    }
    haptic.selectionChanged()
  }
}
