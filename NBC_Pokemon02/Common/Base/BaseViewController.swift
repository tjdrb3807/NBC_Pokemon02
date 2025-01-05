//
//  BaseViewController.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 12/30/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bind()
        self.configureUI()
        self.setupConstraints()
    }
    
    func bind() {
        
    }
    
    func configureUI() {
        view.backgroundColor = UIColor.mainRed
    }
    
    func setupConstraints() {
        
    }
}
