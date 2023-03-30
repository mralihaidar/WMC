//
//  ApplicationTourViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 14/01/22.
//

import UIKit

class ApplicationTourViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [SlideView] = []
    
    override var navigationItemBackButtonTextIsHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createSlides() -> [SlideView] {
        
        let slide1 = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide1.imageView.image = UIImage(named: "slide-1")
        slide1.titleLabel.text = L("intro_content_title_1")
        slide1.descriptionLabel.text = L("intro_content_description_1")
        slide1.delegate = self

        let slide2 = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide2.imageView.image = UIImage(named: "slide-2")
        slide2.titleLabel.text = L("intro_content_title_2")
        slide2.descriptionLabel.text = L("intro_content_description_2")
        slide2.delegate = self

        let slide3 = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide3.imageView.image = UIImage(named: "slide-3")
        slide3.titleLabel.text = L("intro_content_title_3")
        slide3.descriptionLabel.text = L("intro_content_description_3")
        slide3.delegate = self
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides: [SlideView]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
}

extension ApplicationTourViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let view = slides[Int(pageIndex)]
        if pageIndex == 2 {
            view.nextButton.isHidden = false
            view.skipButton.isHidden = true
        } else {
            view.nextButton.isHidden = true
            view.skipButton.isHidden = false
        }
    }
}

extension ApplicationTourViewController: SlideViewDelegate {
    func didSelectNext() {
        let viewController = AuthenticationOptionViewController.instantiateFrom(storyboard: .appTour)
        show(viewController, sender: self)
    }
}
