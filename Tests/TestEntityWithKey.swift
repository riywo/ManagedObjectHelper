//
//  TestEntityWithKey.swift
//  ManagedObjectHelper
//
//  Created by Ryosuke Iwanaga on 2018-08-25.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import Foundation
import CoreData
@testable import ManagedObjectHelper

extension TestEntityWithKey: NSManagedObjectHelperWithKey {
    public static var keyName = "id"
    public typealias KeyType = Int16
}
