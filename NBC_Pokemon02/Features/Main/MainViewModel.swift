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
        let selectedItem: Observable<Int>
    }
    
    struct Output {
        let sectionSubject: BehaviorSubject<PokemonSectionModel>
        let detailViewModel: Observable<DetailViewModel>
    }
    
    private var currentPage = 0
    private let pageSize = 20
    private let isLoding = BehaviorSubject<Bool>(value: false)
    private let sectionSubject = BehaviorSubject(value: PokemonSectionModel(items: []))
    
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
            .filter { vm, _ in vm.canLoadNextPage() }
            .flatMapLatest { vm, _ in
                vm.fetchNextPage()
            }.subscribe()
            .disposed(by: disposeBag)
        
        let detailViewModel = input.selectedItem
            .withLatestFrom(sectionSubject) {
                PokemonDetail(id: $0 + 1, imageURL: $1.items[$0])
            }.map {
                DetailViewModel(model: $0)
            }

        return Output(sectionSubject: sectionSubject,
                      detailViewModel: detailViewModel)
    }
    
    private func canLoadNextPage() -> Bool { (try? !isLoding.value()) ?? false }
    
    private func fetchNextPage() -> Observable<Void> {
        let offset = currentPage * pageSize
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(pageSize)&offset=\(offset)") else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        isLoding.onNext(true)
        
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
                
                var currentSection = try sectionSubject.value()
                currentSection.items.append(contentsOf: newUrls)
                
                self.sectionSubject.onNext(currentSection)
                self.currentPage += 1
            }, onDispose: { [weak self] in
                self?.isLoding.onNext(false)
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
