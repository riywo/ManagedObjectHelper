//
//  NSManagedObjectHelper.swift
//  ManagedObjectHelper
//
//  Created by Ryosuke Iwanaga on 2018-08-20.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import Foundation
import CoreData

public protocol NSManagedObjectHelper {}
public protocol NSManagedObjectHelperWithKey: NSManagedObjectHelper {
    static var keyName: String { get }
    associatedtype KeyType: CVarArg
}

extension NSManagedObjectContext {
    private static var _shared: NSManagedObjectContext?
    
    public static var sharedDefault: NSManagedObjectContext {
        get { return _shared! }
        set { _shared = newValue }
    }
}

extension NSManagedObjectHelper where Self: NSManagedObject {
    public static func request(
        _ predicate: NSPredicate? = nil,
        _ sortDescriptors: [NSSortDescriptor]? = nil,
        _ fetchLimit: Int? = nil) -> NSFetchRequest<Self>
    {
        let request: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
        if predicate != nil { request.predicate = predicate }
        if sortDescriptors != nil { request.sortDescriptors = sortDescriptors }
        if fetchLimit != nil { request.fetchLimit = fetchLimit! }
        return request
    }
    
    public static func fetch(_ request: NSFetchRequest<Self>) -> [Self]? {
        return try? NSManagedObjectContext.sharedDefault.fetch(request)
    }
    
    public static var all: [Self] {
        return fetch(request()) ?? []
    }
    
    public static var count: Int {
        return (try? NSManagedObjectContext.sharedDefault.count(for: fetchRequest())) ?? 0
    }
    
    public static func create() -> Self {
        return Self(context: NSManagedObjectContext.sharedDefault)
    }
    
    public static func search(_ predicate: NSPredicate, _ sortDescriptors: [NSSortDescriptor]? = nil,
                              _ limit: Int? = nil) -> [Self] {
        return fetch(request(predicate, sortDescriptors, limit)) ?? []
    }
    
    public static func search(format: String, _ args: CVarArg...,
        sort: [(key: String, asc: Bool)]? = nil, limit: Int? = nil) -> [Self] {
        let predicate = NSPredicate(format: format, argumentArray: args)
        let sortDescriptors = sort?.map{ NSSortDescriptor(key: $0.key, ascending: $0.asc) }
        return search(predicate, sortDescriptors)
    }
    
    public static func deleteAll() {
        try! NSManagedObjectContext.sharedDefault.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest()))
    }
}

extension NSManagedObjectHelperWithKey where Self: NSManagedObject {
    public static func find(_ id: KeyType) -> Self? {
        return search(format: "%K == %@", keyName, id, limit: 1).first
    }
    
    public static func findOrCreate(_ id: KeyType) -> Self {
        if let existed = find(id) {
            return existed
        } else {
            let new = create()
            new.setValue(id, forKeyPath: keyName)
            return new
        }
    }
}
