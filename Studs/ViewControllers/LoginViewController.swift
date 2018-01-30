//
//  LoginViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  // MARK: Outlets
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: Actions
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard
      let email = emailField.text, !email.isEmpty,
      let password = passwordField.text, !password.isEmpty else {
      return // TODO: show user error
    }
    activityIndicator.startAnimating()
    API.login(email: email, password: password) { result in
      self.activityIndicator.stopAnimating()
      switch result {
      case .success():
        self.performSegue(withIdentifier: "loginSegue", sender: self)
      case .failure(let error):
        // TODO: Show some error to user
        print(error)
      }
    }
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
