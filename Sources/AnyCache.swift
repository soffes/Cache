//
//  AnyCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

public struct AnyCache<Element>: Cache {

	// MARK: - Properties

	private let _get: (String, @escaping (Element?) -> Void) -> ()
	private let _set: (String, Element, (() -> Void)?) -> ()
	private let _remove: (String, (() -> Void)?) -> ()
	private let _removeAll: ((() -> Void)?) -> ()


	// MARK: - Initializers

	public init<C: Cache>(_ cache: C) where Element == C.Element {
		_get = { cache.get(key: $0, completion: $1) }
		_set = { cache.set(key: $0, value: $1, completion: $2) }
		_remove = { cache.remove(key: $0, completion: $1) }
		_removeAll = { cache.removeAll(completion: $0) }
	}


	// MARK: - Cache

	public func get(key: String, completion: @escaping ((Element?) -> Void)) {
		_get(key, completion)
	}

	public func set(key: String, value: Element, completion: (() -> Void)? = nil) {
		_set(key, value, completion)
	}

	public func remove(key: String, completion: (() -> Void)? = nil) {
		_remove(key, completion)
	}

	public func removeAll(completion: (() -> Void)? = nil) {
		_removeAll(completion)
	}
}
