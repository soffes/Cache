//
//  Cache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

public protocol Cache {
	associatedtype Element

	func get(key: String, completion: @escaping ((Element?) -> Void))
	func set(key: String, value: Element, completion: (() -> Void)?)
	func remove(key: String, completion: (() -> Void)?)
	func removeAll(completion: (() -> Void)?)
}
