//
//  WebImageContext.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Combine
import UIKit
import Alamofire
import AlamofireImage

class WebImageContext : NetworkContext<UIImage> {
	
	public static let imageCache = AutoPurgingImageCache()

	var useCache: Bool = false
	
	private var cachedImage: UIImage? {
		
		return self.url.isEmpty ? nil : Self.imageCache.image(withIdentifier: self.url)
	}

	override func send(withSession: Bool = false) -> AnyPublisher<UIImage?, Error> {
		
		if self.useCache,
		   let image = self.cachedImage {
			
			return Just(image).setFailureType(to: Error.self).eraseToAnyPublisher()
		}
		
		return self.send { [weak self] context -> AnyPublisher<UIImage?, Error> in
			
			let operation: DataRequest = AF.request(context.url)
			
			return Deferred {
				
				Future { promise in
					
					operation.responseImage { response in
						
						if case .success(let image) = response.result {
							
							if self?.useCache ?? false {
								
								Self.imageCache.add(image, withIdentifier: context.url)
							}
							
							promise(.success(image))
						}
						else if case .failure(let error) = response.result {
							
							promise(.failure(error))
						}
					}
				}
			}
			.handleEvents(receiveCancel: { [weak operation] in
				
				operation?.cancel()
			})
			.eraseToAnyPublisher()
		}
	}
}

