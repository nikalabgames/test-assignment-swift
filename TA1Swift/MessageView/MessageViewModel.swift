//
//  MessageViewModel.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import UIKit

class MessageViewModel: Model {
	
	let message: SampleMessage
	
	init(message: SampleMessage) {
		self.message = message
		super.init()
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
	
	static let avatarSize = CGSize(width: 36, height: 36)
	static let sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
	var titleHeight: CGFloat { return isMe ? 0 : 26 }
	
	var avatarColor: UIColor { UIColor(red: 198.0 / 255.0, green: 57.0 / 255.0, blue: 255.0 / 255.0, alpha: 1) }
	
	var senderAcronym: String {
		
		if let name = self.message.sender?.senderFullName.components(separatedBy: " ").prefix(2).joined(separator: " ") {
			
			let formatter = PersonNameComponentsFormatter()
			if #available(iOS 15.0, *) {
				formatter.locale = Locale.current
			}
			if let components = formatter.personNameComponents(from: name) {
				 formatter.style = .abbreviated
				 return formatter.string(from: components)
			}
		}
		
		return ""
	}
	
	var isMe: Bool { return message.sender?.isMe ?? false }
	
	var attributedTimeString: NSAttributedString {
		
		let fullString = NSMutableAttributedString(string: "")
		
		if isMe {
			
			let attachment = NSTextAttachment()
			attachment.image = UIImage(named: "check")
			attachment.bounds = CGRectMake(0, -4, 16, 16)
			let imageString = NSAttributedString(attachment: attachment)
			fullString.append(imageString)
			fullString.append(NSAttributedString(string: " "))
		}
		
		fullString.append(NSAttributedString(string: "11:19"))
		return fullString
	}
	
	var mediaCount: Int { message.media?.count ?? 0 }
	
	var maxMediaCount: Int {
		
		if mediaCount > 1 {
			
			let horizontalInset = Self.sectionInset.left + Self.avatarSize.width
			return min(mediaCount, Int((contentSize.width - horizontalInset) / imageSize.width))
		}
		
		return mediaCount
	}
	
	private var mediaSize: CGSize {
		
		if let url = message.media?.first {
			
			let height = (url.lastPathComponent as NSString).doubleValue
			let newUrl = url.deletingLastPathComponent()
			let width = (newUrl.lastPathComponent as NSString).doubleValue
			return CGSize(width: CGFloat(width), height: CGFloat(height))
		}
		
		return .zero
	}
	
	private var maxMediaSize: CGSize {
		
		let isPortrait = UIScreen.main.bounds.width < UIScreen.main.bounds.height
		let horizontalInset = Self.sectionInset.left + Self.avatarSize.width
		let maxWidth = (contentWidth - horizontalInset) * (isPortrait ? 0.85 : 0.5)
		let mediaSize = self.mediaSize
		
		if mediaSize.width > maxWidth {
			
			let scale = maxWidth / mediaSize.width
			return CGSize(width: mediaSize.width * scale, height: mediaSize.height * scale)
		}
		
		return mediaSize
	}
	
	var imageSize: CGSize {
		
		if message.media?.count ?? 0 > 1 {
			
			return CGSize(width: 120, height: 120)
		}
		
		return maxMediaSize
	}
	
	private var contentWidth: CGFloat {
		
		let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
		let horizontalInset = Self.sectionInset.left + Self.sectionInset.right + safeAreaInsets.left + safeAreaInsets.right
		return UIScreen.main.bounds.width - horizontalInset
	}
	
	var contentSize: CGSize {
		
		return CGSize(width: self.contentWidth, height: imageSize.height + (isMe ? 0.0 : self.titleHeight))
	}
}
