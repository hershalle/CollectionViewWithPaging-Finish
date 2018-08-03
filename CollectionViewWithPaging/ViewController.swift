//
//  ViewController.swift
//  CollectionViewWithPaging
//
//  Created by Shai Balassiano on 28/07/2017.
//  Copyright © 2017 Shai Balassiano. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    private var dataSource: [[UIColor]] = [[.bittersweet(), .blizzardBlue(), .blue(), .blueBell(), .blueGreen(), .blueViolet(), .blush(), .brickRed()],
                                           [.almond(), .antiqueBrass(), .apricot(), .aquamarine(), .asparagus(), .atomicTangerine(), .bananaMania(), .beaver()],
                                           [.brilliantRose(), .brown(), .burntOrange(), .burntSienna(), .cadetBlue(), .canary(), .caribbeanGreen(), .carnationPink()],
                                           [.cerise(), .cerulean(), .chestnut(), .copperCrayolaAlternateColor(), .copper(), .cornflowerBlue(), .cottonCandy(), .dandelion()],
                                           [.denim(), .desertSand(), .eggplant(), .electricLime(), .fern(), .forestGreen(), .fuchsia(), .fuzzyWuzzy()],
                                           [.gold(), .goldenrod(), .grannySmithApple(), .gray(), .green(), .greenBlue(), .greenYellow(), .hotMagenta()],
                                           [.inchworm(), .indigo(), .jazzberryJam(), .jungleGreen(), .laserLemon(), .lavender(), .lemonYellow(), .lightBlue()]]
    
    private var indexOfCellBeforeDragging = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewLayout.minimumLineSpacing = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 236 + (cellBodyViewIsExpended ? 174 : 0)
        
        let buttonWidth: CGFloat = 50
        
        let inset = (collectionViewLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewLayout.itemSize.width
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(dataSource.count - 1, index))
        return safeIndex
    }
    
    // ===================================
    // MARK: - UICollectionViewDataSource:
    // ===================================
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsPaletteCollectionViewCell", for: indexPath) as! ColorsPaletteCollectionViewCell
        
        cell.configure(colors: dataSource[indexPath.row]) { (selectedColor: UIColor) in
            self.view.backgroundColor = selectedColor
        }
        
        // You can color the cells so you could see how they behave:
        //        let isEvenCell = CGFloat(indexPath.row).truncatingRemainder(dividingBy: 2) == 0
        //        cell.backgroundColor = isEvenCell ? UIColor(white: 0.9, alpha: 1) : .white
        
        return cell
    }
    
    // =================================
    // MARK: - UICollectionViewDelegate:
    // =================================
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSource.count && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex)
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
