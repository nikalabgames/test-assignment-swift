//
//  NetworkContext.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation
import Combine

enum HTTPMethod: String {
	case GET = "GET"
	case POST = "POST"
	case PUT = "PUT"
	case PATCH = "PATCH"
	case DELETE = "DELETE"
}

class NetworkContext<T>: NSObject {
	
	typealias RequestMapper = (NetworkContext) -> AnyPublisher<T?, Error>
	
	var method = HTTPMethod.GET
	var url = ""
	var params: Dictionary<String, Any> = [:]
	var headers: Dictionary<String, String> = [:]
	@objc dynamic var progress: Double = 0
	
	func send(requestMapper: RequestMapper) -> AnyPublisher<T?, Error> {
		
		if self.url.isEmpty {
			
			return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
		}
		else {
			
			return requestMapper(self)
		}
	}
	
	func send(withSession: Bool = false) -> AnyPublisher<T?, Error> {
		
		return self.send { context -> AnyPublisher<T?, Error> in
			
			return Network.network(withSession: withSession).requestWithContext(context)
		}
	}
}

class Network<T> {
	
	static func network(withSession: Bool) -> Network { Network(withSession: withSession) }
	
	private var withSession: Bool
	
	private init(withSession: Bool = false) {
		
		self.withSession = withSession
	}
	
	func requestWithContext(_ context: NetworkContext<T>) -> AnyPublisher<T?, Error> {
		
		//Sending web request
		let token = withSession ? Session.token : nil
		return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
	}
}
