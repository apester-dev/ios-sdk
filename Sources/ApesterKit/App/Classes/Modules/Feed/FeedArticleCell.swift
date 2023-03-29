//
//  FeedArticleCell.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//

import UIKit
import EzImageLoader

class FeedArticleCell : UICollectionViewCell , Nibable , Reusable
{
    // MARK: - @IBOutlet
    @IBOutlet private weak var       textLabel : UILabel!
    @IBOutlet private weak var detailTextLabel : UILabel!
    @IBOutlet private weak var       imageView : UIImageView!
    @IBOutlet private weak var   containerView : UIView!
    
    // MARK: - overrides
    override func awakeFromNib()
    {
        super.awakeFromNib()
        containerView.backgroundColor = .brown
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.imageView.image = nil
        containerView.backgroundColor = .brown
    }
    
    // MARK: - Public API
    func setupView(with model: FeedModel)
    {
        guard let article = model.content as? FeedModel.Article else { return }
        
        textLabel.text       = article.title
        detailTextLabel.text = article.subtitle
        
        ImageLoader.reset()
        
        ImageLoader.get(article.image_link) { [weak self] result in
            
            guard let strongSelf = self else { return }
            strongSelf.imageView.image = result.image
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
