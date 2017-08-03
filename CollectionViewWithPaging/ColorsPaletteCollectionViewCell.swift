//
//  ColorsPaletteCollectionViewCell.swift
//  CollectionViewWithPaging
//
//  Created by Shai Balassiano on 28/07/2017.
//  Copyright © 2017 Shai Balassiano. All rights reserved.
//

import UIKit

class ColorsPaletteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var colorButton1: UIButton!
    @IBOutlet private weak var colorButton2: UIButton!
    @IBOutlet private weak var colorButton3: UIButton!
    @IBOutlet private weak var colorButton4: UIButton!
    @IBOutlet private weak var colorButton5: UIButton!
    @IBOutlet private weak var colorButton6: UIButton!
    @IBOutlet private weak var colorButton7: UIButton!
    
    private var buttons: [UIButton]!
    
    var didSelectColor: ((UIColor) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [colorButton1,
                   colorButton2,
                   colorButton3,
                   colorButton4,
                   colorButton5,
                   colorButton6,
                   colorButton7]
        
    }
    
    func configure(colors: [UIColor], didSelectColor: ((UIColor) -> ())? = nil) {
        self.didSelectColor = didSelectColor
        
        for (index, button) in buttons.enumerated() {
            button.backgroundColor = colors[index]
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        for button in buttons {
            button.layer.cornerRadius = button.frame.height / 2
        }
    }
    
    @IBAction func didTap(button: UIButton) {
        guard let color = button.backgroundColor else {
            return
        }
        
        didSelectColor?(color)
    }
}
