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
        let loadNextPageTrigger: Observable<Void>
    }
    
    struct Output {
        let thumbnailList: BehaviorSubject<[URL]>
    }
    
    private var currentPage = 0
    private let pageSize = 20
    
    private let listSubject = BehaviorSubject<[URL]>(value: [])
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .take(1)
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.fetchNextPage()
            }.subscribe()
            .disposed(by: disposeBag)
        
        input.loadNextPageTrigger
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.fetchNextPage()
            }.subscribe()
            .disposed(by: disposeBag)
        
        return Output(thumbnailList: listSubject)
    }
    
    private func fetchNextPage() -> Observable<Void> {
        let offset = currentPage * pageSize
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(pageSize)&offset=\(offset)") else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        return NetworkManager.shared.fetch(url: url)
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .asObservable()
            .flatMap { (response: PokemonResponse) in
                Observable.from(response.results)
            }.compactMap { $0.url }
            .withUnretained(self)
            .compactMap { vm, url in
                vm.convertToThumbnailURL(from: url)
            }.toArray()
            .observe(on: MainScheduler.instance)
            .asObservable()
            .do(onNext: { [weak self] newUrls in
                guard let self = self else { return }
                
                var currentList = try self.listSubject.value()
                currentList.append(contentsOf: newUrls)
                self.listSubject.onNext(currentList)
                self.currentPage += 1
            }).map { _ in () }
    }
}

extension MainViewModel {
    func convertToThumbnailURL(from url: URL) -> URL? {
        guard let lastComponent = url.pathComponents.last,
              let id = Int(lastComponent) else { return nil }
        
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}
