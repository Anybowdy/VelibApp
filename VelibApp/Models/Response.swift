//
//  Response.swift
//  VelibApp
//
//  Created by Joseph Huang on 30/06/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

struct Response: Decodable {
    
    var records: [Station]
    
    enum CodingKeys: String, CodingKey {
        case records
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.records = try container.decode([Station].self, forKey: .records)
    }
}
