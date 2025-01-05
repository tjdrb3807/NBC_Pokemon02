//
//  UILabel.swift
//  NBC_Pokemon02
//
//  Created by 전성규 on 1/5/25.
//

import UIKit

extension UILabel {
    static func makeLabel(fontSize: CGFloat, weight: UIFont.Weight, color: UIColor = .white) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        return label
    }
    
    func setFormattedText(_ prefix: String, value: String?, suffix: String = "") {
        self.text = "\(prefix)\(value ?? "알 수 없음")\(suffix)"
    }
}
