//
//  ImageViewController.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 17.11.22.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let url = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        fetchImage()
    }
    
    func fetchImage() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        NetworkManager.downloadImage(url: url) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
}
