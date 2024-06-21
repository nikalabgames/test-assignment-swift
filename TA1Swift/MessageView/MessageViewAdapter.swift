//
//  MessageViewAdapter.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import UIKit

final class MessageViewAdapter: CollectionViewAdapter {
	
	var messages: [MessageViewModel] {
		
		return self.items as? [MessageViewModel] ?? []
	}
	
	override init(reuseIdentifier: String = "") {
		
		super.init(reuseIdentifier: reuseIdentifier)
		
		self.withViewClass(MessageViewCell.self).flowLayout{ collectionView, layout in
			
			layout.sectionInset = MessageViewModel.sectionInset
		}
		.numberOfItems { [weak self] collectionView, section in
			
			return self?.items.count ?? 0
		}
		.sizeForItem { [weak self]  collectionView, indexPath in
			
			return self?.messages[indexPath.row].contentSize ?? .zero
		}
	}
}
