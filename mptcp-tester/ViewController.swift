//
//  ViewController.swift
//  mptcp-tester
//
//  Created by Jan Fornoff on 19.05.18.
//  Copyright © 2018 Jan Fornoff. All rights reserved.
//

import UIKit

struct MPTCPResponse : Codable {
    var mptcp : Bool
}

class ViewController: UIViewController {
    let testButton : UIButton = {
        var button = UIButton(type: UIButtonType.roundedRect)
        button.setTitle("TEST", for: .normal)
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    let resultView : UILabel = {
       var label = UILabel()
        label.backgroundColor = UIColor.lightText
        label.text = "Press to test"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(testButton)
        self.view.addSubview(resultView)
        
        testButton.addTarget(self, action: #selector(doTest), for: .touchUpInside)

        layoutButton()
        layoutResults()
    }
    
    fileprivate func displayError(content : String) {
        self.resultView.backgroundColor = UIColor.red
        self.resultView.text = content
        self.resultView.lineBreakMode = .byWordWrapping
        self.resultView.numberOfLines = 0
    }
    
    
    fileprivate func displaySuccess(content : String) {
        self.resultView.backgroundColor = UIColor.green
        self.resultView.text = content
        self.resultView.lineBreakMode = .byWordWrapping
        self.resultView.numberOfLines = 0
    }
    
    @objc func doTest() {
        debugPrint("Testing MPTCP capability")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.multipathServiceType = .aggregate
        
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: URL(string: "http://amiusingmptcp.de:5900/v1/check_connection")!, completionHandler: {
            (data, response, error) in
            debugPrint("Completed!")
            
            guard error == nil else {
                debugPrint("Error while checking!")
                
                DispatchQueue.main.async {
                    self.displayError(content: error!.localizedDescription)
                }

                return
            }

            do {
                let serverResponse = try JSONDecoder().decode(MPTCPResponse.self, from: data!)
                
                DispatchQueue.main.async {
                    if serverResponse.mptcp {
                        self.displaySuccess(content: "MPTCP is working!")
                    } else {
                        self.displayError(content: "MPTCP does not seem to work!")
                    }
                }
            } catch {
                return
            }
            
            return
        }).resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func layoutButton() {
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        testButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        testButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        testButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        testButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func layoutResults() {
        resultView.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.topAnchor.constraint(equalTo: testButton.bottomAnchor).isActive = true
        resultView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        resultView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

