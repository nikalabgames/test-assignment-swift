//
//  MessageImageViewAdapter.swift
//  TA1Swift
//
//  Created by Andrew on 21.06.2024.
//

final class MessageImageViewAdapter: CollectionViewAdapter {
	
	var model: MessageViewModel?
	
	override init(reuseIdentifier: String = "") {
		
		super.init(reuseIdentifier: reuseIdentifier)
		
		self.withViewClass(MessageImageViewCell.self).flowLayout { collectionView, layout in
			
			layout.sectionInset = .zero
			layout.scrollDirection = .horizontal
			layout.minimumInteritemSpacing = 1
			layout.minimumLineSpacing = 1
		}
		.numberOfItems{ [weak self] collectionView, section in
			
			return self?.model?.maxMediaCount ?? 0
		}
		.sizeForItem { [weak self] collectionView, indexPath in
			
			return self?.model?.imageSize ?? .zero
		}
	}
}
