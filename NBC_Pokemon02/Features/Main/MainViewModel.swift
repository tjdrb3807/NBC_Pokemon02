//
//  MainViewModel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}

final class MainViewModel: ViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let thumbnailList: BehaviorSubject<[URL]>
    }
    
    let listSubject = BehaviorSubject<[URL]>(value: [])
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        fetchPokemonThumbanils(on: input.viewWillAppear)
        
        return Output(thumbnailList: listSubject)
    }
    
    private func fetchPokemonThumbanils(on trigger: Observable<Void>) {
        trigger
            .take(1)
            .compactMap { URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0") }
            .flatMap { NetworkManager.shared.fetch(url: $0) }
            .map { (response: PokemonResponse) in
                response.results.compactMap { $0.url }
            }.flatMap { Observable.from($0) }
            .withUnretained(self)
            .compactMap { vm, url in
                vm.convertToThumbnailURL(from: url)
            }.toArray()
            .subscribe(
                onSuccess: { [weak self] urls in
                    self?.listSubject.onNext(urls)
                }, onFailure: { [weak self] error in
                    self?.listSubject.onError(error)
                }).disposed(by: disposeBag)
    }
}

extension MainViewModel {
    func convertToThumbnailURL(from url: URL) -> URL? {
        guard let lastComponent = url.pathComponents.last,
              let id = Int(lastComponent) else { return nil }
        
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}
