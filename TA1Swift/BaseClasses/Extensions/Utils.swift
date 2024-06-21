//
//  Utils.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

class Once {

	var already: Bool = false
	
	func run(block: () -> Void) {
		
		guard !already else { return }
		
		block()
		already = true
	}
}
