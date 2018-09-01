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
    public static func create() -> Self {
        return Self(context: NSManagedObjectContext.sharedDefault)
    }
    
    public static func request(
        _ predicate: NSPredicate? = nil,
        _ sortDescriptors: [NSSortDescriptor]? = nil,
        _ fetchLimit: Int? = nil) -> NSFetchRequest<Self>
    {
        let request: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors ?? []
        if let limit = fetchLimit { request.fetchLimit = limit }
        return request
    }
    
    public static func fetch(_ request: NSFetchRequest<Self>) -> [Self] {
        return (try? NSManagedObjectContext.sharedDefault.fetch(request)) ?? []
    }
    
    public static func searchRequest(format: String? = nil, args: [CVarArg]? = nil,
        sort: [(key: String, asc: Bool)]? = nil, limit: Int? = nil) -> NSFetchRequest<Self>
    {
        let predicate = format == nil ? nil : NSPredicate(format: format!, argumentArray: args ?? [])
        let sortDescriptors = sort?.map{ NSSortDescriptor(key: $0.key, ascending: $0.asc) }
        return request(predicate, sortDescriptors, limit)
    }
    
    public static func search(format: String? = nil, args: [CVarArg]? = nil,
        sort: [(key: String, asc: Bool)]? = nil, limit: Int? = nil) -> [Self]
    {
        return fetch(searchRequest(format: format, args: args, sort: sort, limit: limit))
    }
    
    public static func all() -> [Self] {
        return search()
    }
    
    public static func count(format: String? = nil, args: [CVarArg]? = nil) -> Int {
        let countRequest = searchRequest(format: format, args: args)
        return (try? NSManagedObjectContext.sharedDefault.count(for: countRequest)) ?? 0
    }
    
    public static func deleteAll() {
        try! NSManagedObjectContext.sharedDefault.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest()))
    }
}

extension NSManagedObjectHelperWithKey where Self: NSManagedObject {
    public static func find(_ id: KeyType) -> Self? {
        return search(format: "%K == %@", args: [keyName, id], limit: 1).first
    }
    
    public static func findOrCreate(_ id: KeyType) -> Self {
        if let existing = find(id) {
            return existing
        } else {
            let new = create()
            new.setValue(id, forKeyPath: keyName)
            return new
        }
    }
}
