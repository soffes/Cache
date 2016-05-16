//
//  AnyCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

public struct AnyCache<T>: Cache {

	// MARK: - Properties

	private let _get: (String, T? -> Void) -> ()
	private let _set: (String, T, (() -> Void)?) -> ()
	private let _remove: (String, (() -> Void)?) -> ()
	private let _removeAll: ((() -> Void)?) -> ()


	// MARK: - Initializers

	public init<C: Cache where T == C.Element>(_ cache: C) {
		_get = { cache.get(key: $0, completion: $1) }
		_set = { cache.set(key: $0, value: $1, completion: $2) }
		_remove = { cache.remove(key: $0, completion: $1) }
		_removeAll = { cache.removeAll(completion: $0) }
	}


	// MARK: - Cache

	public func get(key key: String, completion: (T? -> Void)) {
		_get(key, completion)
	}

	public func set(key key: String, value: T, completion: (() -> Void)? = nil) {
		_set(key, value, completion)
	}

	public func remove(key key: String, completion: (() -> Void)? = nil) {
		_remove(key, completion)
	}

	public func removeAll(completion completion: (() -> Void)? = nil) {
		_removeAll(completion)
	}
}
