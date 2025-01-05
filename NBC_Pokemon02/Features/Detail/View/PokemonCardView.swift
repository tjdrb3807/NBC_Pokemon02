//
//  PokemonCardView.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/3/25.
//

import UIKit
import SnapKit
import Kingfisher
import RxCocoa

final class PokemonCardView: UIView {
    private let contentVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 15.0
        
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let labelVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10.0
        
        return stackView
    }()
    
    private let labelHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 7.0
        
        return stackView
    }()
    
    private let numberLabel = UILabel.makeLabel(fontSize: 25.0, weight: .bold)
    private let nameLabel = UILabel.makeLabel(fontSize: 25.0, weight: .bold)
    private let typeLabel = UILabel.makeLabel(fontSize: 20.0, weight: .semibold)
    private let heightLabel = UILabel.makeLabel(fontSize: 20.0, weight: .semibold)
    private let weightLabel = UILabel.makeLabel(fontSize: 20.0, weight: .semibold)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: PokemonDetail) {
        let koreanName = PokemonTranslator.getKoreanName(for: model.name ?? "")
        let typeName = PokemonTypeName(rawValue: model.type ?? "")?.displayName ?? "알 수 없음"
        let formattedHeight = String(format: "%.1f", Double(model.height ?? 0) / 10.0)
        let formattedWeight = String(format: "%.1f", Double(model.weight ?? 0) / 10.0)

        imageView.kf.setImage(
            with: model.imageURL,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
        numberLabel.text = "No.\(model.id)"
        nameLabel.text = koreanName
        typeLabel.text = "타입: \(typeName)"
        
        heightLabel.setFormattedText("키: ", value: formattedHeight, suffix: " m")
        weightLabel.setFormattedText("몸무게: ", value: formattedWeight, suffix: " kg")
    }
    
    private func configureUI() {
        backgroundColor = UIColor.darkRed
        
        layer.cornerRadius = 12.0
        
        addSubview(contentVStackView)
        
        [imageView, labelVStackView].forEach { contentVStackView.addArrangedSubview($0) }
        
        [labelHStackView, typeLabel, heightLabel, weightLabel].forEach { labelVStackView.addArrangedSubview($0) }
        
        [numberLabel, nameLabel].forEach { labelHStackView.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        contentVStackView.snp.makeConstraints { $0.center.equalToSuperview() }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
}

#if DEBUG

import SwiftUI

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView_Presentable()
            .frame(
                width: UIScreen.main.bounds.width - 20.0,
                height: UIScreen.main.bounds.height / 2,
                alignment: .center)
    }
    
    struct PokemonCardView_Presentable: UIViewRepresentable {
        func makeUIView(context: Context) -> some UIView {
            PokemonCardView()
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }
}

#endif
