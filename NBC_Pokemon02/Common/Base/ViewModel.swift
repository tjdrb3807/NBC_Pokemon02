//
//  ViewModel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/5/25.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
