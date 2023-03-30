//
//  ProfileItemsRequest.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 27/01/22.
//

import Foundation

class ProfileItemsRequest: NetworkRequest {
    var method: RequestType = .GET
    var path = "/profiles/items"
    var parameters = [String: Any]()
}

