//
//  ViewController.swift
//  BloxchainExam
//
//  Created by milky.agora on 6/7/18.
//  Copyright © 2018 milky.agora. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myTableView: UITableView!
    var fieldArray = [Field]()
    var displayWidth = CGFloat()
    var displayHeight =  CGFloat()
    var usersArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tableFooterView = UIView()
        self.view.addSubview(myTableView)
        fetchViewData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(fieldArray.count*35)+20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        let view = UIView(frame: CGRect(x: 20, y: 20, width: Int(displayWidth-20), height: fieldArray.count*30))
        var yConstraint = 0
        for field in fieldArray{
            let f = UITextView(frame: CGRect(x: 0, y: yConstraint, width: Int(displayWidth-40), height: 30))
            f.text = "\(field.label): \((usersArray[indexPath.row] as AnyObject)[field.id] as AnyObject)"
            view.addSubview(f)
            yConstraint += 30
        }
        
        cell.addSubview(view)
        cell.selectionStyle = .none
        return cell
    }
    
    
    func fetchViewData(){
        let url = URL(string: "http://www.mocky.io/v2/5afaa7cd2e00005000279004")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let usableData = data {
                        if let json: NSDictionary = try! JSONSerialization.jsonObject(with: usableData, options: []) as? NSDictionary{
                            print(json)
                            
                            if let elements = json["elements"] as? NSArray{
                                if elements.count > 0{
                                    let element = elements[0] as AnyObject
                                    let userData = element["data"] as? String
                                    if let fields = element["fields"] as? NSArray{
                                        for case let f as AnyObject in fields{
                                            let field = Field()
                                            field.id = f["id"] as! String
                                            field.label = f["label"] as! String
                                            field.type = f["type"] as! String
                                            self.fieldArray.append(field)
                                        }
                                        
                                    }
                                    self.fetchUserData(urlString: userData!)
                                }
                            }
                            
                        }
                    }
                }
            }
            else{
                print(error!.localizedDescription as Any)
            }
        }
        task.resume()
    }
    
    func fetchUserData(urlString: String){
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let usableData = data {
                        if let json: NSDictionary = try! JSONSerialization.jsonObject(with: usableData, options: []) as? NSDictionary{
                            print(json)
                            if let users = json["users"] as? NSArray{
                                self.usersArray = users
                            }
                            
                            self.myTableView.reloadData()
                            
                        }
                    }
                }
            }
            else{
                print(error!.localizedDescription as Any)
            }
        }
        task.resume()
    }
    
    
}
