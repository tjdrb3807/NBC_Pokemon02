//
//  DetailViewModel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/3/25.
//

import Foundation
import RxSwift

final class DetailViewModel: ViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let modelSubject: Observable<PokemonDetail>
    }
    
    private var model: PokemonDetail
    
    var disposeBag = DisposeBag()
    
    init(model: PokemonDetail) {
        self.model = model
    }
    
    func transform(input: Input) -> Output {
        let modelSubject = input.viewWillAppear
            .withUnretained(self)
            .flatMap { vm, _ in
                NetworkManager.shared.fetch(url: URL(string: "https://pokeapi.co/api/v2/pokemon/\(vm.model.id)/")!)
            }.map { (response: PokemonDetailResponse) -> PokemonDetail in
                var updateModel = self.model
                updateModel.name = response.name
                updateModel.type = response.types?.first?.type.name
                updateModel.height = response.height
                updateModel.weight = response.weight
                
                return updateModel
            }
        
        return Output(modelSubject: modelSubject)
    }
}
