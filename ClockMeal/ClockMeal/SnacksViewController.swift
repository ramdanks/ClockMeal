//
//  SnacksViewController.swift
//  ClockMeal
//
//  Created by Ramadhan Kalih Sewu on 28/04/22.
//

import UIKit

class SnacksViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var gradient: Gradient!
    
    let pageSize = 3
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        configureScrollView()
    }
    
    private func configureScrollView()
    {
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: width * CGFloat(pageSize), height: height)
        gradient.frame.size = CGSize(width: width * CGFloat(pageSize), height: height)
        
        for i in 0..<pageSize
        {
            let view = UIImageView(image: UIImage(named: "snack\(i)")!)
            view.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
            scrollView.addSubview(view)
        }
        scrollView.addSubview(gradient)
    }
    
    @IBAction func onGettingSnacksButton(_ sender: UIButton)
    {
        let alert = UIAlertController(
            title: "Taking Snacks",
            message: "I would like to report that i'm having a snack right now",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            let response = Response(type: .snack, date: Date(), skip: false)
            Settings.responses.append(response)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension SnacksViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let idx = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(floor(idx))
    }
}

