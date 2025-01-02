//
//  PokemonHeaderView.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/2/25.
//

import UIKit
import SnapKit

final class PokemonHeaderView: UICollectionReusableView {
    static let identifier = "PokemonHeaderView"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pokemonBall")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(imageView)
        backgroundColor = UIColor.mainRed
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(20.0)
            $0.width.equalTo(imageView.snp.width)
            $0.centerX.equalToSuperview()
        }
    }
    
}
