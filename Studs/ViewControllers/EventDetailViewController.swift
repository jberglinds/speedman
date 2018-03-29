//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class EventDetailViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var beforeSurveyButton: RoundedShadowView!
  @IBOutlet weak var afterSurveyButton: RoundedShadowView!

  // MARK: - Properties
  var event: Event!
  private let locationManager = CLLocationManager()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureSurveyButtons()

    // Do any additional setup after loading the view.
    descriptionLabel.numberOfLines = 0

    title = event.companyName
    descriptionLabel.text = event.privateDescription

    // Lookup coordinates for address and place pin on map
    if let address = event.location {
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address) { placemarks, _ in
        guard let placemarks = placemarks else { return }
        guard let coordinate = placemarks[0].location?.coordinate else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "\(self.event.companyName ?? ""): \(address)"
        self.mapView.addAnnotation(pin)
        self.mapView.showAnnotations([pin], animated: false)
      }
    } else {
      mapView.isHidden = true
    }

    // Try to use location
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
    }

    // Hide button to check-in manager if insufficient permissions
    if let user = UserManager.shared.user,
      !user.permissions.contains(.checkins) {
      // TODO: Separate permission for checkins
      navigationItem.rightBarButtonItem = nil
    }
  }

  /// Hide the event surveys buttons conditionally.
  /// Hides the after survey before the event and hides the before survey
  /// after the event starts.
  func configureSurveyButtons() {
    beforeSurveyButton.isHidden = event.beforeSurveys?.isEmpty ?? true
    afterSurveyButton.isHidden = event.afterSurveys?.isEmpty ?? true
    if let date = event.date {
      if date.compare(Date()) == .orderedDescending {
        afterSurveyButton.isHidden = true
      } else {
        beforeSurveyButton.isHidden = true
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
    super.viewWillDisappear(animated)
  }

  deinit {
    applyMapViewMemoryLeakFix()
  }

  /// Mitigate MKMapView memory leaks
  /// http://www.openradar.me/33400943
  func applyMapViewMemoryLeakFix() {
    switch mapView.mapType {
    case .standard, .mutedStandard:
      mapView.mapType = .satellite
    default:
      mapView.mapType = .standard
    }
    mapView.showsUserLocation = false
    mapView.delegate = nil
    mapView.removeFromSuperview()
    mapView = nil
  }

  // MARK: - Actions
  @IBAction func beforeSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.beforeSurveys?.first else { return }
    openURL(url: url)
  }

  @IBAction func afterSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.afterSurveys?.first else { return }
    openURL(url: url)
  }

  /// Open the given url in a SFSafariViewController
  func openURL(url: String) {
    guard let url = URL(string: url) else { return }
    let safariVC = SFSafariViewController(url: url)
    self.present(safariVC, animated: true)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "checkInSegue":
      if let checkinVC = segue.destination as? CheckInTableViewController {
        checkinVC.event = self.event
      }
    case "checkinButtonSetupSegue":
      if let buttonVC = segue.destination as? CheckinButtonViewController {
        buttonVC.event = self.event
      }
    default:
      break
    }
  }
}
