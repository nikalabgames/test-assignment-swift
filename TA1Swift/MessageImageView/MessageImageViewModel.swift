//
//  MessageImageViewModel.swift
//  TA1Swift
//
//  Created by Andrew on 21.06.2024.
//

import UIKit
import Combine

class MessageImageViewModel: Model {
	
	var image: UIImage?
	var moreImagesCount: Int
	let url: URL
	private var cancellable: Set<AnyCancellable> = []
	
	init(url: URL, moreImagesCount: Int = 0) {
		
		self.url = url
		self.moreImagesCount = moreImagesCount
	}
	
	override func reloadData() {
		
		self.cancellable.forEach { $0.cancel() }
		self.cancellable.removeAll()
		
		let context = WebImageContext()
		context.url = url.absoluteString
		
		context.send().mapError{ [weak self] error in
			
			self?.didReceiveError(error)
			return error
		}
		.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
			
			guard let self else { return }
			self.image = image
			didReceiveModel(self)
		})
		.store(in: &self.cancellable)
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
}
