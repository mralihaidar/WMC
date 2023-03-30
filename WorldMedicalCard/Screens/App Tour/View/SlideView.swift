//
//  SlideView.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 16/01/22.
//

import UIKit

protocol SlideViewDelegate: AnyObject {
    func didSelectNext()
}

class SlideView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    weak var delegate: SlideViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        skipButton.setTitle(L("button_skip_tour"), for: .normal)
        nextButton.setTitle(L("button_next"), for: .normal)
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        delegate?.didSelectNext()
    }
    
    @IBAction func skipButtonTapped(_ sender: AnyObject) {
        delegate?.didSelectNext()
    }
}
