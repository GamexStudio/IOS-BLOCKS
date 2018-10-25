//
//  T&CViewController.swift
//  TRACE_Mobile
//
//  Created by dinesh on 25/01/18.
//  Copyright © 2018 JiniGuru. All rights reserved.
//

import UIKit

class T_CViewController: UIViewController {
    
//    public var termsAndConditions: String? {
//        didSet {
//            self.tncTextView.text = self.termsAndConditions
//        }
//    }
    
//    var titleString: String?
//    var contentString: String?
    
    var termsAndConditions: [String] = [String]()
    
    fileprivate var tncLable:UILabel?
    var webView: UIWebView!
    var fTableRowHeight: CGFloat = 0
//    @IBOutlet weak var tncTextView: UITextView!
    
//    let string = "T's&C's:\n<ul><li>Voucher valid until 31 March 2018.</li><li>Discount voucher can be redeemed from Monday -Thursday</li><li>Vouchers are only valid in SA.</li><li>Vouchers may not be used in conjunction with any other promotion, sale or special offer and valid against regular priced merchandise products only.</li><li>Vouchers cannot be used to purchase cellular products (handsets, airtime or data) Laptops, Printers, Digital Devices, Gaming Consoles, Software or Gaming Accessories, Gift cards.</li><li>This voucher code must be produced in store to qualify.</li><li>Vouchers are no valid for online purchases.</li><li>Only one voucher may be redeemed per transaction and no change will be given against any discount vouchers.<br></li></ul>"
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
//        tncLable = UILabel(frame: self.view.bounds)
//        tncLable?.numberOfLines = 0
//        tncLable?.lineBreakMode = .byWordWrapping
//        self.view.addSubview(tncLable!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension T_CViewController: UITableViewDataSource {    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsAndConditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_title", for: indexPath) as! TCTitleCell
            
            cell.titleTextView.attributedText = termsAndConditions[indexPath.row].TCHeaderFormate().html2AttributedString
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_content", for: indexPath) as! TCContentCell
            cell.IBWebView.delegate = self
            cell.IBWebView.loadHTMLString(termsAndConditions[indexPath.row].TCFormate(), baseURL: nil)
            webView = cell.IBWebView
            return cell
        }
        
        
        
    }
}

extension T_CViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }else {
            return fTableRowHeight
        }
    }
}

extension T_CViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        var frame = webView.frame
        frame.size.height = 1
        webView.frame = frame
        let fittingSize = webView.sizeThatFits(CGSize.zero)
        frame.size = fittingSize
        webView.frame = frame
        fTableRowHeight = fittingSize.height + 60
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        webView.scrollView.isScrollEnabled = false
        print("cell size Value is \(fTableRowHeight)")
    }
}
