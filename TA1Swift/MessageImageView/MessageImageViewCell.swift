//
//  MessageImageView.swift
//  TA1Swift
//
//  Created by Andrew on 21.06.2024.
//

import UIKit
import SnapKit
import Combine

class MessageImageViewCell: View {
	
	override var model: Model? { didSet { self.reloadData() } }
	let imageView = UIImageView()
	let labelImageCount = UILabel()
	let containerImageCount = UIView()
	private var cancellable: Set<AnyCancellable> = []
	
	override func initialize() {
		
		super.initialize()
		self.addSubview(imageView)
		imageView.addSubview(containerImageCount)
		containerImageCount.addSubview(labelImageCount)
		self.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
		
		self.containerImageCount.backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.4)
		
		self.labelImageCount.font = .systemFont(ofSize: 24, weight: .regular)
		self.labelImageCount.textAlignment = .center
		self.labelImageCount.textColor = .white
		
		self.imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		self.containerImageCount.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		self.labelImageCount.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func reloadData() {
		
		self.snp.remakeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let imageCount = (self.model as? MessageImageViewModel)?.moreImagesCount ?? 0
		self.labelImageCount.text = "+\(imageCount)"
		self.containerImageCount.isHidden = imageCount <= 0
		
		self.imageView.alpha = 0
		self.cancellable.forEach { $0.cancel() }
		self.cancellable.removeAll()
		
		self.model?.receiveModelSignal.sink { [weak self] model in
			
			func updateImage(_ image: UIImage?) {
				
				self?.imageView.image = image
				UIView.animate(withDuration: 0.23) {
					
					self?.imageView.alpha = 1
				}
			}
			
			let model = model as? MessageImageViewModel
			
			if #available(iOS 15.0, *) {
				
				model?.image?.prepareForDisplay { image in
					DispatchQueue.main.async {
						updateImage(image)
					}
				}
			} 
			else {
				
				updateImage(model?.image)
			}
			
		}
		.store(in: &self.cancellable)
		
		self.model?.reloadData()
	}
}
