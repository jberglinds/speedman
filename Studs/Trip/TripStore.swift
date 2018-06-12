//
//  State.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Store for tracking the state of the Trip part of the app

import Foundation

struct TripState {
  var activities = [TripActivity]()
  var users = [User]()
  var selectedActivity: TripActivity?
  var drawerPosition = DrawerPosition.partiallyRevealed
  var drawerBottomSafeArea: Float = 0.0
  var drawerPage = DrawerPage.schedule
}

enum DrawerPage {
  case schedule
  case plans
  case information
}

enum DrawerPosition: String {
  case collapsed
  case partiallyRevealed
  case open
}

enum TripAction {
  case selectActivity(TripActivity?)
  case changeDrawerPosition(DrawerPosition)
  case updateActivities([TripActivity])
  case setDrawerBottomSafeArea(Float)
  case changeDrawerPage(DrawerPage)
  case fetchUsers
  case updateUsers([User])
}

class TripStore: Store<TripState, TripAction> {
  private lazy var activitiesSubscription: Subscription<[TripActivity]>? =
    Firebase.streamActivities { [weak self] in
    self?.dispatch(action: .updateActivities($0))
  }

  init() {
    super.init(state: TripState(), reduce: { state, action in
      var state = state
      var command: Command<TripAction>?
      switch action {
      case .selectActivity(let activity):
        state.selectedActivity = activity
      case .changeDrawerPosition(let position):
        state.drawerPosition = position
      case .updateActivities(let activities):
        state.activities = activities
        if let selectedActivity = state.selectedActivity {
          state.selectedActivity = activities.first { selectedActivity.id == $0.id }
        }
      case .changeDrawerPage(let page):
        state.drawerPage = page
      case .setDrawerBottomSafeArea(let newValue):
        state.drawerBottomSafeArea = newValue
      case .updateUsers(let users):
        state.users = users
      case .fetchUsers:
        command = { handler in
          API.getUsers {
            switch $0 {
            case .success(let users):
              handler(.updateUsers(users))
            case .failure(let error):
              print(error)
            }
          }
        }
      }
      return (state, command)
    })
    dispatch(action: .fetchUsers)
  }
}