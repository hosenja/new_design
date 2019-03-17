//
//  RateDialog.swift
//  Snapgroup
//
//  Created by snapmac on 13/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import SwiftHTTP
import FloatRatingView
import TTGSnackbar



class RateDialog: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ratingFloat: FloatRatingView!
    @IBOutlet weak var commentTv: UITextView!
    @IBOutlet weak var fullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTv.delegate = self
        commentTv.text = "Type your text here"
        commentTv.textColor = UIColor.lightGray
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your text here"
            textView.textColor = UIColor.lightGray
        }
    }
    @objc func endEditing() {
        view.endEditing(true)
    }
    @IBAction func submitReview(_ sender: Any) {
        if fullName.text != "" && commentTv.text != "" && commentTv.text != "Type your text here" {
             addCommentFunc()
        }else {
            let snackbar = TTGSnackbar(message: "To write a comment, fill all.", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
    }
    func addCommentFunc(){
        
        let perameters:  [String : Any] = ["model_type": ProviderInfo.model_type!, "model_id": ProviderInfo.model_id!
            ,  "rating": "\(self.ratingFloat.rating)"
            , "review": commentTv.text!, "fullname": (fullName.text)!]
        print(perameters)
        
        HTTP.POST(ApiRouts.Api+"/ratings", parameters: perameters)
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("Success Rate \(response.data)")
            DispatchQueue.main.sync {
                var currentRating: RatingModel = RatingModel()
                currentRating.fullname = (self.fullName.text)!
                currentRating.id = -1
                currentRating.rating = self.ratingFloat.rating
                currentRating.review = self.commentTv.text!
                
                if ((ProviderInfo.model_type)!) == "members" {
                    NotificationCenter.default.post(name: NotificationKey.writeRate_Leader, object: currentRating)
                }else {
                    NotificationCenter.default.post(name: NotificationKey.writeRate_provider, object: currentRating)
                }
               
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        
    }
    
}
