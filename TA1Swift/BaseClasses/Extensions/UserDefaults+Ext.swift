//
//  UserDefaults+Ext.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
	
	var key: String
	var initialValue: T
	private var syncronize: Bool = false
	
	var wrappedValue: T {
		
		set {
			
			UserDefaults.standard.set(newValue, forKey: key)
			
			if syncronize {
				
				CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
			}
		}
		
		get { UserDefaults.standard.object(forKey: key) as? T ?? initialValue }
	}
	
	init(_ key: String, _ defaultValue: T, _ syncronize: Bool = false) {
		
		self.key = key
		self.initialValue = defaultValue
		self.syncronize = syncronize
	}
}

@propertyWrapper
struct UserDefaultOptional<T> {
	
	var key: String
	var initialValue: T?
	private var syncronize: Bool = false
	
	var wrappedValue: T? {
		
		set {
			
			UserDefaults.standard.set(newValue, forKey: key)
			
			if syncronize {
				
				CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
			}
		}
		
		get { UserDefaults.standard.object(forKey: key) as? T ?? initialValue }
	}
	
	init(_ key: String, _ defaultValue: T?, _ syncronize: Bool = false) {
		
		self.key = key
		self.initialValue = defaultValue
		self.syncronize = syncronize
	}
}

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> {
	
	var key: String
	var initialValue: T
	private var syncronize: Bool = false
	
	var wrappedValue: T {
		
		set {
			
			UserDefaults.standard.set(newValue.rawValue, forKey: key)
			
			if syncronize {
				
				CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
			}
		}
		
		get {
			
			guard let value = UserDefaults.standard.object(forKey: key) as? T.RawValue else {
				return initialValue
			}
			
			return T(rawValue: value) ?? initialValue
		}
	}
	
	init(_ key: String, _ defaultValue: T, _ syncronize: Bool = false) {
		
		self.key = key
		self.initialValue = defaultValue
		self.syncronize = syncronize
	}
}
