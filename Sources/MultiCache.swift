//
//  MultiCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

import libkern

/// Reads from the first cache available. Writes to all caches in order. If there is a cache miss and the value is later
/// found in a subsequent cache, it is written to all previous caches.
public struct MultiCache<T>: Cache {

	// MARK: - Properties

	public let caches: [AnyCache<T>]


	// MARK: - Initializers

	public init(caches: [AnyCache<T>]) {
		self.caches = caches
	}


	// MARK: - Cache

	public func set(key: String, value: T, completion: (() -> Void)? = nil) {
		coordinate(block: { cache, finish in
			cache.set(key: key, value: value, completion: finish)
		}, completion: completion)
	}

	public func get(key: String, completion: ((T?) -> Void)) {
		var misses = [AnyCache<T>]()

		func finish(_ value: T?) {
			// Found
			if let value = value {
				// Call completion with the value
				completion(value)

				// Fill previous caches that missed
				for miss in misses {
					miss.set(key: key, value: value, completion: nil)
				}
				return
			}

			// Not in any of the caches
			if misses.count + 1 == self.caches.count {
				completion(nil)
				return
			}

			// Not found in this cache
			misses.append(self.caches[misses.count])

			// Try the next cache
			get(misses.count, key: key, completion: finish)
		}

		// Try the first cache
		get(0, key: key, completion: finish)
	}

	public func remove(key: String, completion: (() -> Void)?) {
		coordinate(block: { cache, finish in
			cache.remove(key: key, completion: finish)
		}, completion: completion)
	}

	public func removeAll(completion: (() -> Void)?) {
		coordinate(block: { cache, finish in
			cache.removeAll(completion: finish)
		}, completion: completion)
	}


	// MARK: - Private

	// Calls the completion block after all messages to all caches are complete.
	private func coordinate(block: ((AnyCache<T>, (() -> Void)) -> Void), completion: (() -> Void)?) {
		// Count starts with the count of caches
		var count = Int32(caches.count)

		let finish: () -> () = {
			// Safely decrement the count
			OSAtomicCompareAndSwap32(count, count - 1, &count)

			// If the count is 0, we're received all of the callbacks.
			if count == 0 {
				// Call the completion
				completion?()
			}
		}

		// Kick off the work for each cache
		caches.forEach { block($0, finish) }
	}

	private func get(_ index: Int, key: String, completion: ((T?) -> Void)) {
		caches[index].get(key: key, completion: completion)
	}
}
