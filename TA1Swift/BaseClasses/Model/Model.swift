//
//  Model.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation
import Combine

class Model: NSObject {
		
	var uuid: String = ""
	@objc dynamic var isLoading: Bool = false
	
	private var receiveModelSubject = PassthroughSubject<Any, Never>()
	
	var receiveModelSignal: AnyPublisher<Model, Never> {
					
		return receiveModelSubject.filter { (v) -> Bool in
			
			return !(v is Error)
		}
		.map { [weak self] (v) -> Model in
			
			return self!
		}
		.eraseToAnyPublisher()
	}
	
	var receiveErrorSignal: AnyPublisher<Error, Never> {
		
		return receiveModelSubject.filter { (v) -> Bool in
			
			return v is Error
		}
		.map({ (e) -> Error in
			
			return e as! Error
		})
		.eraseToAnyPublisher()
	}
	
	var loadingSignal: AnyPublisher<Bool, Never> {
		
		return self.publisher(for: \.isLoading).removeDuplicates().eraseToAnyPublisher()
	}
	
	var isValid: Bool {
		
		return self.uuid.count > 0
	}
	
	func didReceiveModel(_ model: Model) -> Void {
		
		self.isLoading = false
		self.receiveModelSubject.send(self)
	}
	
	func didReceiveError(_ error: Error) -> Void {
		
		self.isLoading = false
		self.receiveModelSubject.send(error)
	}
	
	@objc func reloadData() -> Void {
		
		self.isLoading = true
		self.didReceiveModel(self)
	}
	
	override func isEqual(_ object: Any?) -> Bool {
		
		if let object = object as? Model, (object.uuid.count > 0 || self.uuid.count > 0)  {
			
			return self.uuid == object.uuid
		}
		
		return super.isEqual(object)
	}
	
	override var hash: Int {
		
		return super.hash
	}
	
	override func copy() -> Any {

		let copy = Self() as Model
		copy.uuid = self.uuid
		copy.isLoading = self.isLoading
		
		return copy
	}
	
	required override init() {
		
		super.init()
	}
}
