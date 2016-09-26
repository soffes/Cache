//
//  DiskCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

import Foundation

/// Disk cache. All reads run concurrently. Writes wait for all other queue actions to finish and run one at a time
/// using dispatch barriers.
public struct DiskCache<T: NSCoding>: Cache {

	// MARK: - Properties

	private let directory: String
	private let fileManager = FileManager()
	private let queue = DispatchQueue(label: "com.samsoffes.cache.disk-cache", attributes: .concurrent)


	// MARK: - Initializers

	public init?(directory: String) {
		var isDirectory: ObjCBool = false
		// Ensure the directory exists
		if fileManager.fileExists(atPath: directory, isDirectory: &isDirectory) && isDirectory.boolValue {
			self.directory = directory
			return
		}

		// Try to create the directory
		do {
			try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
			self.directory = directory
		} catch {}

		return nil
	}


	// MARK: - Cache

	public func get(key: String, completion: @escaping ((T?) -> Void)) {
		let path = pathForKey(key)

		coordinate {
			let value = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? T
			completion(value)
		}
	}

	public func set(key: String, value: T, completion: (() -> Void)? = nil) {
		let path = pathForKey(key)
		let fileManager = self.fileManager

		coordinate(barrier: true) {
			if fileManager.fileExists(atPath: path) {
				do {
					try fileManager.removeItem(atPath: path)
				} catch {}
			}

			NSKeyedArchiver.archiveRootObject(value, toFile: path)
		}
	}

	public func remove(key: String, completion: (() -> Void)? = nil) {
		let path = pathForKey(key)
		let fileManager = self.fileManager

		coordinate {
			if fileManager.fileExists(atPath: path) {
				do {
					try fileManager.removeItem(atPath: path)
				} catch {}
			}
		}
	}

	public func removeAll(completion: (() -> Void)? = nil) {
		let fileManager = self.fileManager
		let directory = self.directory

		coordinate {
			guard let paths = try? fileManager.contentsOfDirectory(atPath: directory) else { return }

			for path in paths {
				do {
					try fileManager.removeItem(atPath: path)
				} catch {}
			}
		}
	}


	// MARK: - Private

	private func coordinate(barrier: Bool = false, block: @escaping () -> Void) {
		if barrier {
			queue.async(flags: .barrier, execute: block)
			return
		}

		queue.async(execute: block)
	}

	private func pathForKey(_ key: String) -> String {
		return (directory as NSString).appendingPathComponent(key)
	}
}
