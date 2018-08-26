//
//  ManagedObjectHelperTests.swift
//  ManagedObjectHelperTests
//
//  Created by Ryosuke Iwanaga on 2018-08-20.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import XCTest
import CoreData
@testable import ManagedObjectHelper

class ManagedObjectHelperTests: XCTestCase {
    let bundle = Bundle(for: ManagedObjectHelperTests.self)
    let testModel = "TestModel"
    
    lazy var container: NSPersistentContainer = {
        // Since .xctest bundle can't be accessd by `Bundle.main`, we have to declare mom explicitly
        // You don't have to do this in your iOS App
        let momUrl = bundle.url(forResource: testModel, withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: momUrl)!
        let container = NSPersistentContainer(name: testModel, managedObjectModel: mom)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error { XCTFail("Failed to load store: \(error)") }
        }
        return container
    }()
    
    override func setUp() {
        func setUpTestEntity() {
            TestEntity.deleteAll()
            TestEntity.create().id = 1
            TestEntity.create().id = 1
            TestEntity.create().id = 2
            try! NSManagedObjectContext.sharedDefault.save()
        }
        
        func setUpTestEntityWithKey() {
            TestEntityWithKey.deleteAll()
            _ = TestEntityWithKey.findOrCreate(1)
            _ = TestEntityWithKey.findOrCreate(1)
            _ = TestEntityWithKey.findOrCreate(2)
            try! NSManagedObjectContext.sharedDefault.save()
        }
        
        super.setUp()
        NSManagedObjectContext.sharedDefault = container.viewContext
        setUpTestEntity()
        setUpTestEntityWithKey()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHelper() {
        XCTAssertEqual(TestEntity.countAll, 3)
        XCTAssertEqual(TestEntity.search(format: "id = %d", 1).count, 2)
        XCTAssertEqual(TestEntity.search(format: "id = %d", 2).count, 1)
        XCTAssertEqual(TestEntity.count(format: "id = %d", 1), 2)
        XCTAssertEqual(TestEntity.count(format: "id = %d", 2), 1)
        XCTAssertEqual(TestEntityWithKey.countAll, 2)
        XCTAssertEqual(TestEntityWithKey.search(format: "id = %d", 1).count, 1)
        XCTAssertEqual(TestEntityWithKey.search(format: "id = %d", 2).count, 1)
        XCTAssertEqual(TestEntityWithKey.count(format: "id = %d", 1), 1)
        XCTAssertEqual(TestEntityWithKey.count(format: "id = %d", 2), 1)
    }
}
