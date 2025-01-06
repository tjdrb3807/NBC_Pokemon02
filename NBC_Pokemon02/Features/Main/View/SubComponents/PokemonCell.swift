//
//  PokemonCell.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import UIKit
import Kingfisher

final class PokemonCell: UICollectionViewCell {
    static let identifier = "PokemonCell"
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.kf.indicatorType = .activity
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
        thumbnailImageView.kf.cancelDownloadTask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = UIColor.cellBackground
        layer.cornerRadius = 12.0
        clipsToBounds = true
        
        contentView.addSubview(thumbnailImageView)
        
        thumbnailImageView.frame = contentView.bounds
    }
    
    func configure(with url: URL) {
        thumbnailImageView.kf.setImage(
            with: url,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}
