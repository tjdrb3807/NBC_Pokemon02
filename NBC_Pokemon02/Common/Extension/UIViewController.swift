//
//  UIViewController.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/5/25.
//

import RxSwift
import UIKit
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        
        return ControlEvent(events: source)
    }
}
