//
//  ProfileViewController.swift
//  Image_Pick_Complete
//
//  Created by Mr. Naveen Kumar on 18/04/21.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameTextFiled: DesignableUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextFiled.layer.cornerRadius = 50
    }

}

