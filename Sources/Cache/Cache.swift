public protocol Cache {
	associatedtype Element

	func get(key: String, completion: @escaping ((Element?) -> Void))
	func set(key: String, value: Element, completion: (() -> Void)?)
	func remove(key: String, completion: (() -> Void)?)
	func removeAll(completion: (() -> Void)?)
}
