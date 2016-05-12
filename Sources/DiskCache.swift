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
struct DiskCache<T: NSCoding>: Cache {

	// MARK: - Properties

	private let directory: String
	private let fileManager = NSFileManager()
	private let queue = dispatch_queue_create("com.samsoffes.cache.disk-cache", DISPATCH_QUEUE_CONCURRENT)


	// MARK: - Initializers

	init?(directory: String) {
		var isDirectory: ObjCBool = false
		// Ensure the directory exists
		if fileManager.fileExistsAtPath(directory, isDirectory: &isDirectory) && isDirectory {
			self.directory = directory
			return
		}

		// Try to create the directory
		do {
			try fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
			self.directory = directory
		} catch {}

		return nil
	}


	// MARK: - Cache

	func get(key key: String, completion: (T? -> Void)) {
		let path = pathForKey(key)

		coordinate {
			let value = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? T
			completion(value)
		}
	}

	func set(key key: String, value: T, completion: (() -> Void)?) {
		let path = pathForKey(key)
		let fileManager = self.fileManager

		coordinate(barrier: true) {
			if fileManager.fileExistsAtPath(path) {
				do {
					try fileManager.removeItemAtPath(path)
				} catch {}
			}

			NSKeyedArchiver.archiveRootObject(value, toFile: path)
		}
	}

	func remove(key key: String, completion: (() -> Void)?) {
		let path = pathForKey(key)
		let fileManager = self.fileManager

		coordinate {
			if fileManager.fileExistsAtPath(path) {
				do {
					try fileManager.removeItemAtPath(path)
				} catch {}
			}
		}
	}

	func removeAll(completion completion: (() -> Void)?) {
		let fileManager = self.fileManager
		let directory = self.directory

		coordinate {
			guard let paths = try? fileManager.contentsOfDirectoryAtPath(directory) else { return }

			for path in paths {
				do {
					try fileManager.removeItemAtPath(path)
				} catch {}
			}
		}
	}


	// MARK: - Private

	private func coordinate(barrier barrier: Bool = false, block: () -> Void) {
		if barrier {
			dispatch_barrier_async(queue, block)
			return
		}

		dispatch_async(queue, block)
	}

	private func pathForKey(key: String) -> String {
		return (directory as NSString).stringByAppendingPathComponent(key)
	}
}
