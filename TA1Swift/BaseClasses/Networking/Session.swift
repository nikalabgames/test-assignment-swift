//
//  TASession.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation

class Session : NSObject {
	
	@UserDefault("TASession.Token", "0")
	private (set) static var token: String
	
	@UserDefault("TASession.User", "00")
	public static var userId: String
	
	private override init() {}
	
	class var isValid: Bool { !Self.token.isEmpty }
	
	class func create(token: String, userId: String) {
		
		Self.token = token
		Self.userId = userId
	}
	
	class func clear() {
		
		Self.token = ""
		Self.userId = ""
	}
}
