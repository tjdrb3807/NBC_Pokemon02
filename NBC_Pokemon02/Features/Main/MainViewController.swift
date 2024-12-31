//
//  MainViewController.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MainViewController: BaseViewController {
    let viewModel = MainViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createFlowLayout(itemPerRow: 3.0, spacing: 10.0, horizontalPadding: 10.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.identifier)
        collectionView.backgroundColor = UIColor.darkRed
        
        return collectionView
    }()
    
    override func bind() {
        let input = MainViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.thumbnailList
            .bind(to: collectionView.rx.items(
                cellIdentifier: PokemonCell.identifier,
                cellType: PokemonCell.self)) { _, url, cell in
                    cell.configure(with: url)
                }.disposed(by: disposeBag)
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.verticalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    private func createFlowLayout(itemPerRow: CGFloat, spacing: CGFloat, horizontalPadding: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let totalSpacing = spacing * (itemPerRow - 1) + (horizontalPadding * 2)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemPerRow
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: horizontalPadding, bottom: spacing, right: horizontalPadding)
        
        return layout
    }
}

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        
        return ControlEvent(events: source)
    }
}

#if DEBUG

import SwiftUI

struct MainViewController_Previews: PreviewProvider {
    static var previews: some View {
        MainViewController_Presentable()
            .edgesIgnoringSafeArea(.all)
            .previewDevice("iPhone 16")
    }
    
    struct MainViewController_Presentable: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            MainViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}

#endif
