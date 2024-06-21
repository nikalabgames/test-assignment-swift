//
//  View.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation
import UIKit

protocol ViewProtocol: UIView {
	
	static func view() -> Self
}

protocol ViewModelProtocol: UIView {

	var model: Model? { get set }
}

class View: UIView, ViewProtocol, ViewModelProtocol {
	
	@IBInspectable
	@objc var passthroughTouches: Bool = false
	
	var model: Model?
	private let initializeOnce = Once()
	private let viewDidLoadOnce = Once()
	
	class func view() -> Self {
		
		let classString = String(describing: self)

		if (Bundle.main.path(forResource: classString, ofType:"nib") != nil) {
			
			return Bundle.main.loadNibNamed(classString, owner:nil, options:nil)?.first as? Self ?? self.init()
		}
		
		return self.init()
	}

	required init?(coder: NSCoder) {
		
		super.init(coder: coder)
	}

	override init(frame:CGRect) {
		
		super.init(frame:frame)
		self._initialize()
	}

	required convenience init() {
		
		self.init(frame:CGRect.zero)
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		self._initialize()
	}

	private func _initialize() {
		
		initializeOnce.run {
			
			initialize()
		}
	}
	
	func initialize() {
		
	}
	
	override func willMove(toWindow newWindow: UIWindow?) {
		
		super.willMove(toWindow: newWindow)
		
		if newWindow != nil {
		
			viewDidLoadOnce.run { [weak self] in
								
				guard let self = self else { return }
				self.viewDidLoad()
			}
		}
	}

	func viewDidLoad() {

	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		
		let hitView = super.hitTest(point, with:event)

		if self.passthroughTouches && hitView == self {
			
			return nil
		}

		return hitView
	}
}
