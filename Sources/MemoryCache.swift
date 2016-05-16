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

	private let cache = NSCache()


	// MARK: - Initializers

	#if os(iOS) || os(tvOS)
		public init(countLimit: Int? = nil, automaticallyRemoveAllObjects: Bool = false) {
			cache.countLimit = countLimit ?? 0

			if automaticallyRemoveAllObjects {
				let notificationCenter = NSNotificationCenter.defaultCenter()
				notificationCenter.addObserver(cache, selector: #selector(NSCache.removeAllObjects), name: UIApplicationDidEnterBackgroundNotification, object: nil)
				notificationCenter.addObserver(cache, selector: #selector(NSCache.removeAllObjects), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
			}
		}

		deinit {
			NSNotificationCenter.defaultCenter().removeObserver(cache)
		}
	#else
		public init(countLimit: Int? = nil) {
			cache.countLimit = countLimit ?? 0
		}
	#endif


	// MARK: - Cache

	public func set(key key: String, value: T, completion: (() -> Void)? = nil) {
		cache.setObject(Box(value), forKey: key)
		completion?()
	}

	public func get(key key: String, completion: (T? -> Void)) {
		let box = cache.objectForKey(key) as? Box<T>
		let value = box.flatMap({ $0.value })
		completion(value)
	}

	public func remove(key key: String, completion: (() -> Void)? = nil) {
		cache.removeObjectForKey(key)
		completion?()
	}

	public func removeAll(completion completion: (() -> Void)? = nil) {
		cache.removeAllObjects()
		completion?()
	}
	
	
	// MARK: - Synchronous
	
	public subscript(key: String) -> T? {
		get {
			return (cache.objectForKey(key) as? Box<T>)?.value
		}
		
		set(newValue) {
			if let newValue = newValue {
				cache.setObject(Box(newValue), forKey: key)
			} else {
				cache.removeObjectForKey(key)
			}
		}
	}
}
