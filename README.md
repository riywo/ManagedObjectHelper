# ManagedObjectHelper
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/riywo/PreloadedPersistentContainer/master/LICENSE.txt)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A Framework to extend `NSManagedObject` with some static helper functions. Two of initial intents of this Framework are 1) to avoid type casting by users 2) to keep a default `NSManagedObjectContext` for avoiding context when calling methods.

## Examples

### `NSManagedObjectHelper`
```swift
NSManagedObjectContext.sharedDefault = container.viewContext

extension Entity: NSManagedObject: NSManagedObjectHelper {
}

Entity.all      // => Fetch all objects
Entity.count    // => Return total count
Entity.create() // => Return a new object to store

Entity.search(
    format: "foo == %d", 1,
    sort: [(key: "bar", asc: true)],
    limit: 10)  // => Fetch with predicate, sort, and limit
```

### `NSManagedObjectHelperWithKey`
```swift
NSManagedObjectContext.sharedDefault = container.viewContext

extension Entity: NSManagedObject: NSManagedObjectHelperWithKey {
    public static var keyName = "id"
    public typealias KeyType = Int16
}

Entity.find(1)          // Fetch by key or nil
Entity.findOrCreate(1)  // Find an existing object or create a new one
```

## Install

Using `Carthage`:

```sh
$ cat Cartfile
github "riywo/ManagedObjectHelper"

$ carthage update
*** Fetching ManagedObjectHelper
*** Checking out ManagedObjectHelper at "v0.1.0"
*** xcodebuild output can be found in /var/folders/29/mmyrpb0d5g39glgdcv9x4z780000gn/T/carthage-xcodebuild.PBBnLr.log
*** Building scheme "ManagedObjectHelper iOS" in ManagedObjectHelper.xcodeproj
*** Building scheme "ManagedObjectHelper macOS" in ManagedObjectHelper.xcodeproj
```

Now, you can use Framework:

```
./Carthage/Build
├── Mac
│   ├── ManagedObjectHelper.framework
│   └── ManagedObjectHelper.framework.dSYM
└── iOS
    ├── ManagedObjectHelper.framework
    └── ManagedObjectHelper.framework.dSYM
```

## Usage

TODO