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
import RxDataSources

final class MainViewController: BaseViewController {
    private let viewModel = MainViewModel()
    
    private var isRead: Bool = false
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<PokemonSectionModel>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PokemonCell.identifier,
                for: indexPath) as? PokemonCell else { return UICollectionViewCell() }
            
            cell.configure(with: item)
            
            return cell
        },
        configureSupplementaryView: { _, collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: PokemonHeaderView.identifier,
                    for: indexPath) as? PokemonHeaderView else { return UICollectionReusableView() }
                
                return header
            }
            
            return UICollectionReusableView()
        })
    
    private lazy var collectionView: UICollectionView = {
        let layout = createFlowLayout(itemPerRow: 3.0, spacing: 10.0, horizontalPadding: 10.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(PokemonHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PokemonHeaderView.identifier)
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.identifier)
        collectionView.backgroundColor = UIColor.darkRed
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        return collectionView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        isRead = true
    }
    
    override func bind() {
        let input = MainViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable(),
            loadNextPageTrigger: collectionView.rx.didScroll
                .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
                .withUnretained(self)
                .filter { vc, _ in
                    vc.isRead && vc.isNearBottom()
                }.map { _ in () },
            selectedItem: collectionView.rx.itemSelected.map { $0.row }
        )
        
        let output = viewModel.transform(input: input)
        
        output.sectionSubject
            .map { [$0] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.detailViewModel
            .withUnretained(self)
            .subscribe(onNext: { vc, viewModel in
                let detailVC = DetailViewController(viewModel: viewModel)
                vc.navigationController?.pushViewController(detailVC, animated: true)
            }).disposed(by: disposeBag)
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
    
    private func isNearBottom() -> Bool {
        let contentOffsetY = collectionView.contentOffset.y
        let maximumOffset = collectionView.contentSize.height - collectionView.frame.size.height
        
        return maximumOffset - contentOffsetY <= 300
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 150)
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
