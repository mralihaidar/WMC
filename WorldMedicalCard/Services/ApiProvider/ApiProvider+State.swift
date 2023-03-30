//
//  ApiProvider+State.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/8/22.
//

import UIKit

extension ApiProvider {
    enum State {
        case loading
        case success
        case error(Error)
    }
}
