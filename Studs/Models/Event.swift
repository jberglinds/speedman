//
//  Event.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct Event: Codable {
  let id: String
  let companyName: String?
  let schedule: String?
  let location: String?
  let privateDescription: String?
  let date: String?
}
