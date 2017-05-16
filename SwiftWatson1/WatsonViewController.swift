//
//  WatsonViewController.swift
//  SwiftWatson1
//
//  Created by 宮本一彦 on 2016/12/07.
//  Copyright © 2016年 宮本一彦. All rights reserved.
//

import UIKit
import Social

class WatsonViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var passImage = UIImage()
    var resultString = String()
    
    
    // SNS用画面
    var myComposeView:SLComposeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = passImage
        
        getImage(image: passImage)
    }

    @IBAction func shareButton(_ sender: Any) {
        
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        myComposeView.setInitialText(resultString)
        myComposeView.add(imageView.image)
        
        self.present(myComposeView, animated: true, completion: nil)
        
    }
    
    func getImage(image:UIImage){
        
        let apiKey = "4a91102314fde6ff17414bf695f3f9bf10444979"
        let url = "https://gateway-a.watsonplatform.net/calls/image/ImageGetRankedImageKeywords?imagePostMode=raw&outputMode=json&apikey=" + apiKey
        
        let myURL = URL(string: url)!
        let request = NSMutableURLRequest(url: myURL)
        request.httpMethod = "POST"
        request.setValue("aplplication/x-www-form-urlencode", forHTTPHeaderField: "Contet-Type")
        
        let maxSize:Double = 1024 * 768
        var raito:CGFloat = 1
        
        if Double(image.size.width * image.size.height)>maxSize {
            raito = CGFloat(maxSize/Double(image.size.width * image.size.height))
        }
        
        let imageData = UIImageJPEGRepresentation(image, raito)
        request.httpBody = imageData!
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data,response,error in
            
            if let error = error {
                print(error)
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:AnyObject]
                var textArray = [String()]
                var scoreArray = [String()]
                
                textArray.removeAll()
                scoreArray.removeAll()
                
                if let items = json["imageKeywords"] as? [[String:AnyObject]] {
                    
                    for item in items {
                        guard let marker = item["text"] as? String else {
                            continue
                        }
                        guard let name = item["score"] as? String else {
                            continue
                        }
                        
                        textArray.append(marker)
                        scoreArray.append(name)
                    }
                }
                
                let number = scoreArray[0]
                let number2 = Double(number)! * 100.0
                
                self.resultString = "この画像で象徴的なキーワードは" + textArray[0] + "その確率は " + String(number2) + "% " + "From 人工知能Watsonより"
                
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
