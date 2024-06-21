//
//  MessageViewCell.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import UIKit
import SnapKit

class MessageViewCell: View {
	
	let fullNameLabel = UILabel()
	let metaLabel = UILabel()
	let timeLabel = UILabel()
	let timeContainer = UIView()
	let avatarLabel = UILabel()
	let avatarImageView = UIImageView()
	private let containerView = UIView()
	private let titleContainerView = UIView()
	private var adapter: MessageImageViewAdapter { collectionView.adapter as! MessageImageViewAdapter }
	private let collectionView = CollectionView(adapter: MessageImageViewAdapter())
	
	override var model: Model? { didSet { self.reloadData() } }
	
	override func initialize() {
		
		super.initialize()
		self.addSubview(containerView)
		self.addSubview(avatarLabel)
		avatarLabel.addSubview(avatarImageView)
		containerView.addSubview(collectionView)
		containerView.addSubview(titleContainerView)
		containerView.addSubview(timeContainer)
		timeContainer.addSubview(timeLabel)
		titleContainerView.addSubview(fullNameLabel)
		titleContainerView.addSubview(metaLabel)
		
		self.titleContainerView.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
		
		self.fullNameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
		self.fullNameLabel.textColor = UIColor(red: 0.0 / 255.0, green: 157.0 / 255.0, blue: 232.0 / 255.0, alpha: 1)
		
		self.metaLabel.font = .systemFont(ofSize: 11, weight: .regular)
		self.metaLabel.textColor = UIColor(red: 142.0 / 255.0, green: 142.0 / 255.0, blue: 147.0 / 255.0, alpha: 1)
		
		self.timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
		self.timeLabel.textColor = .white
		
		self.timeContainer.backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.4)
		self.timeContainer.layer.cornerRadius = 10
		self.timeContainer.clipsToBounds = true
		
		self.containerView.clipsToBounds = true
		self.containerView.backgroundColor = .clear
		self.containerView.layer.cornerRadius = 12
		
		self.collectionView.isScrollEnabled = false
		self.collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		self.avatarLabel.translatesAutoresizingMaskIntoConstraints = false
		self.avatarLabel.layer.cornerRadius = MessageViewModel.avatarSize.height * 0.5
		self.avatarLabel.textAlignment = .center
		self.avatarLabel.textColor = .white
		self.avatarLabel.clipsToBounds = true
	}
	
	private func setupConstraints(model: MessageViewModel) {
		
		self.snp.remakeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		containerView.snp.remakeConstraints { make in
			
			make.top.bottom.equalToSuperview()
			make.width.equalTo(model.imageSize.width * CGFloat(model.maxMediaCount))
			
			if model.isMe {
				
				make.trailing.equalToSuperview()
			}
			else {
				
				make.leading.equalTo(avatarLabel.snp.trailing).offset(MessageViewModel.sectionInset.left)
			}
		}
		
		var titleHeight: CGFloat {
			
			return model.titleHeight
		}
		
		titleContainerView.snp.remakeConstraints { make in
			make.leading.top.trailing.equalToSuperview()
			make.height.equalTo(titleHeight)
		}
		
		fullNameLabel.snp.remakeConstraints { make in
			make.top.bottom.equalToSuperview().inset(2)
			make.leading.equalToSuperview().inset(10)
			make.trailing.equalTo(metaLabel.snp.leading).offset(-4)
		}
		
		var metaWidth: CGFloat {
			
			self.metaLabel.sizeToFit()
			return self.metaLabel.frame.width
		}
		
		metaLabel.snp.remakeConstraints { make in
			make.top.bottom.equalToSuperview().inset(2)
			make.trailing.equalToSuperview().inset(10)
			make.width.equalTo(metaWidth)
		}
		
		var timeWidth: CGFloat {
			
			self.timeLabel.sizeToFit()
			return self.timeLabel.frame.width + 20
		}
		
		timeContainer.snp.remakeConstraints { make in
			make.height.equalTo(20)
			make.width.equalTo(timeWidth)
			make.trailing.bottom.equalToSuperview().inset(4)
		}
		
		timeLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(4)
			make.leading.trailing.equalToSuperview().inset(10)
		}
		
		collectionView.snp.remakeConstraints { make in
			make.top.equalTo(titleContainerView.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
		
		avatarLabel.snp.remakeConstraints { make in
			
			make.size.equalTo(MessageViewModel.avatarSize)
			make.leading.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		self.setupConstraints(model: self.model as! MessageViewModel)
	}
	
	public func reloadData(withLayout: Bool = false) {
		
		if let model = model as? MessageViewModel {
			
			self.titleContainerView.isHidden = model.isMe
			self.fullNameLabel.text = model.message.sender?.senderFullName
			self.metaLabel.text = model.message.sender?.senderMeta
			self.timeLabel.attributedText = model.attributedTimeString
			
			self.avatarLabel.isHidden = model.isMe
			self.avatarLabel.text = model.senderAcronym
			self.avatarLabel.backgroundColor = model.avatarColor
			
			let moreImagesCount = model.mediaCount - model.maxMediaCount
			let lastIndex = model.maxMediaCount - 1
			var index = 0
			
			self.timeContainer.backgroundColor = moreImagesCount > 0 ? .clear : UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.4)
			
			self.adapter.model = model
			self.adapter.items = model.message.media?.map{
				
				let mediaCount = (index == lastIndex ? moreImagesCount : 0)
				index += 1
				return MessageImageViewModel(url: $0, moreImagesCount: mediaCount)
			} ?? []
			self.collectionView.reloadData(withLayout: withLayout)
		}
	}
	
	public func reloadLayout() {
		
		self.collectionView.reloadLayout()
	}
}
