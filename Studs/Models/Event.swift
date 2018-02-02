//
//  Event.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

struct Event: Decodable {
  let id: String
  let companyName: String?
  let schedule: String?
  let location: String?
  let privateDescription: String?
  let date: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case companyName
    case schedule
    case location
    case privateDescription
    case date
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    companyName = try container.decode(String?.self, forKey: .companyName)
    schedule = try container.decode(String?.self, forKey: .schedule)
    location = try container.decode(String?.self, forKey: .location)
    privateDescription = try container.decode(String?.self, forKey: .privateDescription)

    let dateString = try container.decode(String?.self, forKey: .date)
    date = Formatter.iso8601Fractional.date(from: dateString ?? "")
  }
}

extension Formatter {
  static let iso8601Fractional: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
}
