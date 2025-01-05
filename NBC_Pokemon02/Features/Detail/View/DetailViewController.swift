//
//  DetailViewController.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/3/25.
//

import UIKit
import SnapKit
import RxSwift

final class DetailViewController: BaseViewController {
    private let viewModel: DetailViewModel
    
    private let cardView = PokemonCardView()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bind() {
        let input = DetailViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.modelSubject
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, model in
                vc.cardView.configure(with: model)
            }).disposed(by: disposeBag)
    }
    
    override func configureUI() {
        super.configureUI()
        
        navigationController?.navigationBar.isHidden = false
        
        view.addSubview(cardView)
    }
    
    override func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(20.0)
            $0.height.equalTo(UIScreen.main.bounds.width)
        }
    }
}

#if DEBUG

import SwiftUI

struct DetailViewController_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewController_Presentable()
            .edgesIgnoringSafeArea(.all)
    }
    
    struct DetailViewController_Presentable: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            let vm = DetailViewModel(model: PokemonDetail(
                id: 1,
                imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png")!))
            let vc = DetailViewController(viewModel: vm)
            
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}

#endif
