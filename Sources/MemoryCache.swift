//
//  MemoryCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

#if os(iOS) || os(tvOS)
	import UIKit
#else
	import Foundation
#endif

public final class MemoryCache<T>: Cache {

	// MARK: - Properties

	private let storage = NSCache<NSString, Box<T>>()


	// MARK: - Initializers

	#if os(iOS) || os(tvOS)
		public init(countLimit: Int? = nil, automaticallyRemoveAllObjects: Bool = false) {
			storage.countLimit = countLimit ?? 0

			if automaticallyRemoveAllObjects {
				let notificationCenter = NotificationCenter.default
				notificationCenter.addObserver(storage, selector: #selector(type(of: storage).removeAllObjects), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
				notificationCenter.addObserver(storage, selector: #selector(type(of: storage).removeAllObjects), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
			}
		}
	#else
		public init(countLimit: Int? = nil) {
			storage.countLimit = countLimit ?? 0
		}
	#endif


	// MARK: - Cache

	public func set(key: String, value: T, completion: (() -> Void)? = nil) {
		storage.setObject(Box(value), forKey: key as NSString)
		completion?()
	}

	public func get(key: String, completion: @escaping ((T?) -> Void)) {
		let box = storage.object(forKey: key as NSString)
		let value = box.flatMap({ $0.value })
		completion(value)
	}

	public func remove(key: String, completion: (() -> Void)? = nil) {
		storage.removeObject(forKey: key as NSString)
		completion?()
	}

	public func removeAll(completion: (() -> Void)? = nil) {
		storage.removeAllObjects()
		completion?()
	}
	
	
	// MARK: - Synchronous
	
	public subscript(key: String) -> T? {
		get {
			return (storage.object(forKey: key as NSString))?.value
		}
		
		set(newValue) {
			if let newValue = newValue {
				storage.setObject(Box(newValue), forKey: key as NSString)
			} else {
				storage.removeObject(forKey: key as NSString)
			}
		}
	}
}
