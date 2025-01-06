//
//  MainViewModel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: ViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let loadNextPageTrigger: Observable<Void>
        let selectedItem: Observable<Int>
        let prefetchTrigger: Observable<[IndexPath]>
    }
    
    struct Output {
        let sectionSubject: BehaviorRelay<PokemonSectionModel>
        let detailViewModel: Observable<DetailViewModel>
    }
    
    private var currentPage = 0
    private let pageSize = 20
    private var currentItemCount: Int { sectionRelay.value.items.count }
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let sectionRelay = BehaviorRelay(value: PokemonSectionModel(items: []))
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 화면이 나타날 때 첫 페이지를 로드
        input.viewWillAppear
            .take(1)
            .withUnretained(self)
            .flatMap { vm, _ in vm.fetchNextPage() }
            .subscribe()
            .disposed(by: disposeBag)
        
        // 스크롤 이벤트로 다음 페이지를 로드
        input.loadNextPageTrigger
            .withUnretained(self)
            .filter { vm, _ in vm.canLoadNextPage() }
            .flatMapLatest { vm, _ in vm.fetchNextPage() }
            .subscribe()
            .disposed(by: disposeBag)
        
        input.prefetchTrigger
            .withUnretained(self)
            .filter { vm, indexPaths in
                guard let maxIndex = indexPaths.map({ $0.row }).max() else { return false }
                
                return vm.canPrefetch(at: maxIndex)
            }.flatMapLatest { vm, _ in vm.fetchNextPage() }
            .subscribe()
            .disposed(by: disposeBag)
        
        // 선택된 아이템의 디테일 ViewModel 생성
        let detailViewModel = input.selectedItem
            .withLatestFrom(sectionRelay) { PokemonDetail(id: $0 + 1, imageURL: $1.items[$0])}
            .map { DetailViewModel(model: $0) }

        return Output(sectionSubject: sectionRelay,
                      detailViewModel: detailViewModel)
    }
    
    private func canPrefetch(at maxIndex: Int) -> Bool { maxIndex > currentItemCount - 10 && !isLoading.value }
    
    /**
     다음 페이지를 로드할 수 있는지 확인합니다.
     
     - Returns: 로딩 가능 여부
     */
    private func canLoadNextPage() -> Bool { !isLoading.value }
    
    /**
     다음 페이지의 데이터를 서버에서 가져옵니다.
     
     - Returns: Void Observable
     */
    private func fetchNextPage() -> Observable<Void> {
        let offset = currentPage * pageSize
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(pageSize)&offset=\(offset)") else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        isLoading.accept(true)
        
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
                
                // 새로운 URL 데이터를 기존 데이터에 추가
                var currentSection = sectionRelay.value
                currentSection.items.append(contentsOf: newUrls)
                
                self.sectionRelay.accept(currentSection)
                self.currentPage += 1
            }, onDispose: { [weak self] in
                self?.isLoading.accept(false)
            }).map { _ in () }
    }
}

extension MainViewModel {
    /**
     API에서 가져온 URL을 썸네일 URL로 변환합니다.
     
     - Parameters:
     - url: 원본 URL
     - Returns: 썸네일 URL
     */
    func convertToThumbnailURL(from url: URL) -> URL? {
        guard let lastComponent = url.pathComponents.last,
              let id = Int(lastComponent) else { return nil }
        
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}
