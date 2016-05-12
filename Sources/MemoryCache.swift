//
//  MemoryCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

import UIKit

final class MemoryCache<T>: Cache {

	// MARK: - Properties

	private let cache = NSCache()


	// MARK: - Initializers

	init(countLimit: Int? = nil, automaticallyRemoveAllObjects: Bool = false) {
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


	// MARK: - Cache

	func set(key key: String, value: T, completion: (() -> Void)?) {
		cache.setObject(Box(value), forKey: key)
		completion?()
	}

	func get(key key: String, completion: (T? -> Void)) {
		let box = cache.objectForKey(key) as? Box<T>
		let value = box.flatMap({ $0.value })
		completion(value)
	}

	func remove(key key: String, completion: (() -> Void)?) {
		cache.removeObjectForKey(key)
		completion?()
	}

	func removeAll(completion completion: (() -> Void)?) {
		cache.removeAllObjects()
		completion?()
	}
}
