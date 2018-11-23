//
//

import UIKit
import WebKit
import SafariServices


class CMSListViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,WKUIDelegate, WKNavigationDelegate,UITextFieldDelegate,SFSafariViewControllerDelegate {
  
   
    // Type
    enum TYPE:Int{
        case HTML = 0
        case PDF = 1
        case IMAGE = 2
    }
    
    //Child node position:
    enum POSITION:Int{
        case TOP = 0
        case BOTTOM = 1
        case INBETWEEN = 2
    }
    
    
    
    //IBoutlet
    @IBOutlet weak var tblTopNodeList   : UITableView!
    @IBOutlet weak var tblBottomNodeList: UITableView!
    
    @IBOutlet weak var viewHTML: UIView!
    @IBOutlet weak var viewPDF: UIView!
    @IBOutlet weak var viewIMAGE: UIView!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewWebview: UIView!
    
    
    //Webview
    @IBOutlet weak var webviewTopPosition   : UIWebView!
    @IBOutlet weak var webviewBottomPosition: UIWebView!
    
    
    
    @IBOutlet weak var txtViewPDFHeader: UITextView!
    @IBOutlet weak var txtViewPDFFooter: UITextView!
    
    @IBOutlet weak var txtViewImageHeader: UITextView!
    @IBOutlet weak var txtViewImageFooter: UITextView!
    

    
    @IBOutlet weak var imgLogo: UIImageView!
    
    // Constraint
    @IBOutlet var webViewTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tblNodeTopHeightConstraint: NSLayoutConstraint!

    @IBOutlet var webViewBottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tblNodeBottomHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var imgLogoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var txtViewPDFHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet var txtViewPDFFooterHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var txtViewImageHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet var txtViewImageFooterHeightConstraint: NSLayoutConstraint!
    
   
    @IBOutlet weak var btnExpand: UIButton!
    
    @IBOutlet weak var viewExpand: UIView!
    
    
    @IBOutlet weak var txtTopSearch: UITextField!
    @IBOutlet weak var txtBottomSearch: UITextField!
    @IBOutlet var txtTopSearcheHeightConstraint: NSLayoutConstraint!
    @IBOutlet var txtBottomSearchHeightConstraint: NSLayoutConstraint!
    

    
    //lazy var txtSearch = UITextField()
    //Variable
   @objc var deepLinkId : Int = 0
    var arrAllNodes = [[String:Any]]()
    var searchResults = [[String:Any]]()
    var arrItemData = [[String:Any]]()
    

    
    var webViewHTML : UIWebView!
    var webViewPDF  : UIWebView!
    var webViewIMAGE: UIWebView!
    var webViewExpand: UIWebView!
    
    
    var isSearching : Bool = false
    var strUrlForPDF : String = ""
    
    struct Category {
        let name : String
       var items = [[String:Any]]()
    }
    
    var arrSections = [String: Any]()
    

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.intialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
            self.navigationController?.navigationBar.backgroundColor = .white

        } else {
            // Fallback on earlier versions
        }
    }
    
    

    func intialSetup() -> Void {

        btnExpand.isHidden = true
        txtTopSearch.delegate = self
        txtBottomSearch.delegate = self
        
        txtTopSearch.layer.cornerRadius = 5.0
        txtBottomSearch.layer.cornerRadius = 5.0
        
        self.viewExpand.isHidden = true
        
        webViewTopHeightConstraint.constant = 5.0
        self.tblNodeBottomHeightConstraint.constant = 5.0
        
        
        
        self.tblTopNodeList.estimatedRowHeight = 44.0
//        self.tblTopNodeList.rowHeight = UITableView.automaticDimension
        self.tblTopNodeList.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tblBottomNodeList.estimatedRowHeight = 44.0
//        self.tblBottomNodeList.rowHeight = UITableView.automaticDimension
        self.tblBottomNodeList.tableFooterView = UIView(frame: CGRect.zero)
        
        //Temporary Comment
        //self.imgLogo.alpha = 0.1

        //Call CMS SYNC SERVICE
        AppDelegate.sharedInstance()?.cmsSyncService()
        self.getLocalData()
        if let imgIcon = UIImage(named: "Find.png"){
            txtTopSearch.setLeftIcon(imgIcon)
            txtBottomSearch.setLeftIcon(imgIcon)
        }
        
        if((AppDelegate.sharedInstance()?.reachable())!){
            DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                self!.downloadImages()
            }
        }
    }
    
   
    //MARK:- Get CMS Data
    
    func getLocalData ()-> Void{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CMS")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "(parentid == %d || id == %d) AND (isDeletedItem == %d) ", deepLinkId,deepLinkId,0)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            var arrCatName = [[String:Any]]()
        var arrSecond = [[String: Any]]()
        do {
            let result = try AppDelegate.sharedInstance()?.managedObjectContext.fetch(request)
            var itemDictionary = [String:Any]()
            for data in result as! [NSManagedObject] {
                itemDictionary["id"] = data.value(forKey: "id") as! Int
                itemDictionary["parentid"] = data.value(forKey: "parentid") as! Int
                itemDictionary["title"] = data.value(forKey: "title") as! String
                itemDictionary["type"] = data.value(forKey: "type") as! Int
                itemDictionary["brandImage"] = data.value(forKey: "brandImage") as! String
                itemDictionary["brandColor"] = data.value(forKey: "brandColor") as! String
                itemDictionary["created_at"] = data.value(forKey: "created_at") as! String
                itemDictionary["updated_at"] = data.value(forKey: "updated_at") as! String
                itemDictionary["deleted_at"] = data.value(forKey: "deleted_at") as! String
                itemDictionary["description"] = data.value(forKey: "itemDescription") as! String
                itemDictionary["childNodePosition"] = data.value(forKey: "childNodePosition") as! Int
                itemDictionary["file"] = data.value(forKey: "file") as! String
                itemDictionary["headerTitle"] = data.value(forKey: "headerTitle") as! String
                itemDictionary["headerSubtitle"] = data.value(forKey: "headerSubtitle") as! String
                itemDictionary["footerTitle"] = data.value(forKey: "footerTitle") as! String
                itemDictionary["footerSubTitle"] = data.value(forKey: "footerSubTitle") as! String
                if let nodeTitle = data.value(forKey: "cmsheaderTitle") as? String{
                    itemDictionary["cmsheaderTitle"] = nodeTitle
                }
                else{
                    itemDictionary["cmsheaderTitle"] = ""
                }
                itemDictionary["catId"] = data.value(forKey: "catId") as! Int
                itemDictionary["catName"] = data.value(forKey: "catName") as! String
                
                
                if (itemDictionary["id"] as? Int != deepLinkId){
                    //Add All items in array which match  parentId = deeplinkId
                    arrAllNodes.append(itemDictionary)
                }
                else{
                    //Add item in array Only id == deeplinkId
                    arrItemData.append(itemDictionary)
                }
                
                //if Cat id is one == NONE
                 if data.value(forKey: "catId") as! Int == 1{
//                    arrCatName.removeAll()
                    arrCatName.append(itemDictionary)
                    arrSections[data.value(forKey: "catName") as! String] = arrCatName
                    print("arr section count \(arrSections.count)")
//                    arrSections.append(Category(name: "NONE", items: arrCatName))
                 }
                 else{
                    if(!Array(arrSections.keys).contains(data.value(forKey: "catName") as! String)) {
                        arrSecond.removeAll()
                    }
//                    arrCatName.removeAll()
                    arrSecond.append(itemDictionary)
                    arrSections[data.value(forKey: "catName") as! String] = arrSecond
                    
                    
//                    arrSections.append(Category(name: "OTHERS", items: arrCatName))
                    
                 }
                
                
                
            }
            
            
//            for i in 0..<arrSections.count {
//                print(arrSections[i])
//
//            }
            
            

            
            // set title
            if let title = arrItemData.first?["title"] as? String{
                //self.navigationItem.title = title
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
                label.backgroundColor = .clear
                label.numberOfLines = 0
                label.textAlignment = .center
                label.font = UIFont.boldSystemFont(ofSize: 14.0)
                label.text = "\(title)\n\(AppDelegate.sharedInstance()?.strCmsParentTitle ?? "")" 
                self.navigationItem.titleView = label
            }
            
          
            
            //Set Brand logo here
            if arrItemData.first?["brandImage"] != nil && arrItemData.first?["brandImage"] as? String != ""	{
                let imgURL  = arrItemData.first?["brandImage"] as? String
                let strImgName = URL(string: imgURL ?? "")?.lastPathComponent
                if ((AppDelegate.sharedInstance()?.reachable())!){
                    imgLogo.sd_setImage(with: URL(string:imgURL!)) { (image, error, cache, url) in
                        if (error == nil){
                            self.imgLogoHeightConstraint.constant = 58
                        }
                        else{
                            self.imgLogoHeightConstraint.constant = 0
                        }
                        self.imgLogo.layoutIfNeeded()
                    }
                }
                else{
                    //offline
                    if ((AppDelegate.sharedInstance()?.imageExist(inDocument:strImgName))!){
                        let localPath = AppDelegate.sharedInstance()?.getDocumentPath(withFileName: strImgName)
                        if let strPath = localPath{
                            let url = URL(fileURLWithPath: strPath)
                            imgLogo.sd_setImage(with: url) { (image, error, cache, url) in
                                if (error == nil){
                                    self.imgLogoHeightConstraint.constant = 58
                                }
                                else{
                                    self.imgLogoHeightConstraint.constant = 0
                                }
                                self.imgLogo.layoutIfNeeded()
                            }
                        }
                        
                    }
                    else{
                        self.imgLogoHeightConstraint.constant = 0
                    }
                    
                }
            }
            else
            {
                // find out current items parentID and get brand image
                let parentId = arrItemData.first?["parentid"] as? Int
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CMS")
                request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: "id == %d ", parentId ?? 0)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try AppDelegate.sharedInstance()?.managedObjectContext.fetch(request)
                    var itemDictionary = [String:Any]()
                    
                    for data in result as! [NSManagedObject] {
                        itemDictionary["brandImage"] = data.value(forKey: "brandImage") as! String
                        itemDictionary["brandColor"] = data.value(forKey: "brandColor") as! String
                    }
                    
                    if itemDictionary.count > 0{
                        if let imgURL: String = itemDictionary["brandImage"] as? String{
                            let strImgName = URL(string: imgURL)?.lastPathComponent
                            var strFinalUrl = ""
                            
                            if ((AppDelegate.sharedInstance()?.reachable())!){
                                strFinalUrl = imgURL
                            }
                            else{
                                //offline
                                if ((AppDelegate.sharedInstance()?.imageExist(inDocument:strImgName))!){
                                    let localPath = AppDelegate.sharedInstance()?.getDocumentPath(withFileName: strImgName)
                                    if let strPath = localPath{
                                        let url = URL(fileURLWithPath: strPath)
                                        strFinalUrl  = url.absoluteString
                                    }
                                }
                            }
                            
                            imgLogo.sd_setImage(with: URL(string:strFinalUrl)) { (image, error, cache, url) in
                                if (error == nil){
                                    self.imgLogoHeightConstraint.constant = 58
                                }
                                else{
                                    self.imgLogoHeightConstraint.constant = 0
                                }
                                self.imgLogo.layoutIfNeeded()
                            }
                            
                        }
                        else{
                            self.imgLogoHeightConstraint.constant = 0
                        }
                    }
                    
                }
                catch{
                    
                }
                
            }
            
            // based on type we decide which layout need to show
            if let type : Int = arrItemData.first?["type"] as? Int{
                if type == TYPE.PDF.rawValue {
                    self.viewPDF.isHidden   = false
                    self.viewHTML.isHidden  = true
                    self.viewIMAGE.isHidden = true
                    
                    let hexString = arrItemData.first?["brandColor"] as? String
                    self.viewPDF.backgroundColor = UIColor.init(hexFromString: hexString ?? "#ffffff")

                    
                    if let headerText = arrItemData.first?["headerTitle"] as? String{
                        
                        if let subtitletext = arrItemData.first?["headerSubtitle"] as? String{
                            
                            
                            let str1 = headerText
                            let str2 = subtitletext
                           
//                            let attrsBold = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
//                            let attrsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)];
                            
//                            let attributedStringstr1 = NSMutableAttributedString(string:str1,attributes: attrsBold)
//                            let attributedStringstr2 = NSMutableAttributedString(string: "\n")
//                            let attributedStringstr3 = NSMutableAttributedString(string: str2, attributes: attrsNormal)
                            
                            let final = NSMutableAttributedString()
                            
//                            final.append(attributedStringstr1)
                            if (subtitletext.count > 0){
//                            final.append(attributedStringstr2)
                            }
//                            final.append(attributedStringstr3)
                            self.txtViewPDFHeader.attributedText = final
                            
                          
                            //("\(myMutableString)\n\(myMutableStringsubtitletext)")
                        }
                        else{
                            
                            let headerString:NSString = headerText as NSString
                            var myMutableStringHeader = NSMutableAttributedString()
//                            myMutableStringHeader = NSMutableAttributedString(string: headerString as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0, weight: .bold)])

                            self.txtViewPDFHeader.attributedText = myMutableStringHeader
                        }
                        //Header title and header subtitle available
                        let headerSubtitle = arrItemData.first?["headerSubtitle"] as? String ?? ""
                        if headerSubtitle.count > 0 || headerText.count > 0{
                             self.txtViewPDFHeaderHeightConstraint.constant = self.txtViewPDFHeader.contentSize.height + 10
                        }
                        else{
                            self.txtViewPDFHeaderHeightConstraint.constant = 0.0
                        }
                        
                        
                    }
                    else{
                         self.txtViewPDFHeaderHeightConstraint.constant = 0
                    }
                    if let footerText = arrItemData.first?["footerTitle"] as? String{
                       
                        if let subtitletext = arrItemData.first?["footerSubTitle"] as? String{
                            self.txtViewPDFFooter.text  = ("\(footerText)\n\(subtitletext)")
                        }
                        else{
                            self.txtViewPDFFooter.text = footerText
                        }
                        //footerTitle and footerSubTitle text available
                        let footerSubtitle = arrItemData.first?["footerSubTitle"] as? String
                        if footerText.count > 0 || (footerSubtitle?.count)! > 0{
                            self.txtViewPDFFooterHeightConstraint.constant = self.txtViewPDFFooter.contentSize.height
                           
                        }
                        else{
                            self.txtViewPDFFooterHeightConstraint.constant = 0
                        }
                        
                    }
                    else{
                        self.txtViewPDFFooterHeightConstraint.constant = 0
                    }
                    self.view.layoutIfNeeded()
                    self.txtViewPDFFooter.layoutIfNeeded()

                   //set pdf
                    if let file = arrItemData.first?["file"] as? String {
                        if ((AppDelegate.sharedInstance()?.reachable())!){
                            self.setPDF(file, isLocal: false)
                        }
                        else{
                            //offline
                            let strURL = URL(string: file)?.lastPathComponent
                            if let strFileName = strURL {
                                if((AppDelegate.sharedInstance()?.imageExist(inDocument: strFileName))!){
                                    let localPath = AppDelegate.sharedInstance()?.getDocumentPath(withFileName: strFileName)
                                    if let strPath = localPath{
                                        let url = URL(fileURLWithPath: strPath)
                                        self.setPDF(url.absoluteString,isLocal: true)
                                    }
                                }
                            }
                        }
                    }
                }
                    //SET IMAGE
                else if type == TYPE.IMAGE.rawValue {
                    self.viewIMAGE.isHidden  = false
                    self.viewPDF.isHidden    = true
                    self.viewHTML.isHidden   = true
                    
                    let hexString = arrItemData.first?["brandColor"] as? String
                    self.viewIMAGE.backgroundColor = UIColor.init(hexFromString: hexString ?? "#ffffff")
                    
                    if let headerText = arrItemData.first?["headerTitle"] as? String{
                        let subtitletext : String = arrItemData.first?["headerSubtitle"] as? String ?? ""
                        
                        if  subtitletext.count > 0 {
                            
                            let myString:NSString = headerText as NSString
                            var myMutableStringHeader = NSMutableAttributedString()
//                            myMutableStringHeader = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0, weight: .bold)])
                            
                            var myMutableStringSubtitletext = NSMutableAttributedString()
//                            myMutableStringSubtitletext = NSMutableAttributedString(string: subtitletext as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12.0)])
                            
                            
                            let combination = NSMutableAttributedString()
                            combination.append(myMutableStringHeader)
                            combination.append(NSAttributedString(string: "\n"))
                            combination.append(myMutableStringSubtitletext)
                            
                            self.txtViewImageHeader.attributedText = combination
                            //self.txtViewImageHeader.text = ("\(headerText)\n\(subtitletext)")
                        }
                        else{
                            
                            let headerString:NSString = headerText as NSString
                            var myMutableStringHeader = NSMutableAttributedString()
//                            myMutableStringHeader = NSMutableAttributedString(string: headerString as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0, weight: .bold)])
                            
                            self.txtViewImageHeader.attributedText = myMutableStringHeader
                            
                        }
                        
                        //Set Textview Size if Header title and header subtitle available
                        let headerSubtitle = arrItemData.first?["headerSubtitle"] as? String ?? ""
                        if headerSubtitle.count > 0 || headerText.count > 0{
                           self.txtViewImageHeaderHeightConstraint.constant = self.txtViewImageHeader.contentSize.height + 10
                        }
                        else{
                            self.txtViewImageHeaderHeightConstraint.constant = 0
                        }
                        
                    }
                    else{
                        self.txtViewImageHeaderHeightConstraint.constant = 0
                    }
                    if let footerText = arrItemData.first?["footerTitle"] as? String{
                        if let subtitletext = arrItemData.first?["footerSubTitle"] as? String{
                            self.txtViewImageFooter.text  = ("\(footerText)\n\(subtitletext)")
                        }
                        else{
                            self.txtViewImageFooter.text = footerText
                        }

                        //footerTitle and footerSubTitle text available
                        let footerSubtitle = arrItemData.first?["footerSubTitle"] as? String
                        if footerText.count > 0 || (footerSubtitle?.count)! > 0{
                            self.txtViewImageFooterHeightConstraint.constant = self.txtViewImageFooter.contentSize.height
                        }
                        else{
                            self.txtViewImageFooterHeightConstraint.constant = 0
                        }
                        
                        
                    }
                    else{
                        self.txtViewImageFooterHeightConstraint.constant = 0
                    }
                    self.view.layoutIfNeeded()
                    self.txtViewImageFooter.layoutIfNeeded()
                    
                    //set image
                    if let fileURL:String = arrItemData.first?["file"] as? String{
                        if (fileURL.count != 0){
                            if ((AppDelegate.sharedInstance()?.reachable())!){
                                self.setImageWithURL(fileURL, isLocal: false)
                            }
                            else{
                                //offline
                                let strURL = URL(string: fileURL)?.lastPathComponent
                                if let strFileName = strURL {
                                    if((AppDelegate.sharedInstance()?.imageExist(inDocument: strFileName))!){
                                        let localPath = AppDelegate.sharedInstance()?.getDocumentPath(withFileName: strFileName)
                                        if let strPath = localPath{
                                            let url = URL(fileURLWithPath: strPath)
                                            self.setImageWithURL(url.absoluteString, isLocal: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                else if type == TYPE.HTML.rawValue {
                    
                    let hexString = arrItemData.first?["brandColor"] as? String
                    self.viewHTML.backgroundColor = UIColor.init(hexFromString: hexString ?? "#ffffff")
                    
                    self.viewHTML.isHidden   = false
                    self.viewIMAGE.isHidden  = true
                    self.viewPDF.isHidden    = true
                }
                else{
                    
                    self.viewHTML.isHidden   = true
                    self.viewIMAGE.isHidden  = true
                    self.viewPDF.isHidden    = true
                }
            }
            
            
            //check position
            if let position : Int = arrItemData.first?["childNodePosition"] as? Int{
                
                if position == POSITION.TOP.rawValue{
                    self.viewTop.isHidden = false
                    self.viewBottom.isHidden = true
                    self.viewWebview.isHidden = true
                    if (arrItemData.first?["description"]) != nil{
                        let desc : String = arrItemData.first?["description"] as! String
                         webviewTopPosition.delegate = self
                        if ((AppDelegate.sharedInstance()?.reachable())!){
                            let strWithCss = AppDelegate.sharedInstance()?.cmsCSSHTMLStyle(desc)
                            webviewTopPosition.loadHTMLString(strWithCss ?? desc, baseURL: nil)
                        }
                        else{
                            //offline
                            let strLocalHtml = AppDelegate.sharedInstance()?.getLocalImagePath(desc)
                            
                            let strWithCss = AppDelegate.sharedInstance()?.cmsCSSHTMLStyle(strLocalHtml)
                            
                            webviewTopPosition.loadHTMLString(strWithCss ?? "", baseURL: nil)
                        }
                        webviewTopPosition.reload()
                        webviewTopPosition.scalesPageToFit = false
                        
                    }
                    else{
                       self.heightView(0,position: POSITION.TOP)
                    }
                }
                else if position == POSITION.BOTTOM.rawValue{
                    self.viewBottom.isHidden = false
                    self.viewTop.isHidden = true
                    self.viewWebview.isHidden = true
                    let desc : String = arrItemData.first?["description"] as! String
                    
                    if ( desc.count > 0) {
                        let desc : String = arrItemData.first?["description"] as! String
                        webviewBottomPosition.delegate = self
                        webviewBottomPosition.loadHTMLString(desc, baseURL: nil)
                    }
                    else{
                       
                        if (arrAllNodes.count > 0){
                            
                            self.heightView(0,position: POSITION.BOTTOM)
                        }
                        else{
                            self.heightView(0,position: POSITION.BOTTOM)
                        }
                        
                        
                    }
                }
                else if position == POSITION.INBETWEEN.rawValue{
                    
                    self.viewWebview.isHidden = false
                    self.viewBottom.isHidden = true
                    self.viewTop.isHidden = true
                    if (arrItemData.first?["description"]) != nil{
                        self.viewWebview.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        let desc : String = arrItemData.first?["description"] as! String
                        webViewHTML = UIWebView()
                        webViewHTML.delegate = self
                        webViewHTML.loadHTMLString(desc, baseURL: nil)
                        //webViewHTML.scalesPageToFit = true
                        webViewHTML.frame  = self.viewWebview.bounds;
                        self.viewWebview.addSubview(webViewHTML)
                    
                        
                    }
                    else{
                        self.heightView(0,position: POSITION.BOTTOM)
                    }
                }
                else{
                    print("******* Position not found *******")
                    self.viewTop.isHidden = true
                    self.viewBottom.isHidden = true
                    self.viewWebview.isHidden = true
                }
            }
            
            
        } catch {
            
            print("Failed")
        }
        
    }
   
    //MARK:- SetHeight Of ViewContent
    func heightView(_ textviewHeight:CGFloat , position : POSITION) -> Void {
        if position == POSITION.TOP{
            let screenHeight = (self.viewTop.frame.height * 0.7)
            //if Html content mode then 70% of the screen
            if (textviewHeight >= screenHeight){
                //if having no nodes then make full size of webview
                if arrAllNodes.count == 0 {
                    self.txtTopSearch.isHidden = true
                    self.txtTopSearcheHeightConstraint.constant = 0
                    self.webviewTopPosition.autoPinEdge(toSuperviewEdge: .top)
                    webViewTopHeightConstraint.constant = self.viewTop.frame.height 
                    self.tblNodeTopHeightConstraint.constant = 0
                    
                }
                else{
                    //if having nodes
                    self.txtTopSearch.isHidden = false
                    self.txtTopSearcheHeightConstraint.constant = 30
                    webViewTopHeightConstraint.constant = screenHeight
                    self.tblNodeTopHeightConstraint.constant = (self.viewTop.frame.height - screenHeight)
                }
                
            }
            else{
                //if having no nodes then make full size of webview
                if arrAllNodes.count == 0 {
                    self.txtTopSearcheHeightConstraint.constant = 0
                    self.txtTopSearch.isHidden = true
                    webViewTopHeightConstraint.constant = self.viewTop.frame.height
                    self.tblNodeTopHeightConstraint.constant = 0
                }
                else{
                    //if having nodes
                    self.txtTopSearcheHeightConstraint.constant = 30
                    self.txtTopSearch.isHidden = false
                    webViewTopHeightConstraint.constant = textviewHeight //textviewHeight + 20
                    self.tblNodeTopHeightConstraint.constant = (self.viewTop.frame.height - (webViewTopHeightConstraint.constant + 0))
                }
            }
            
            self.webviewTopPosition.layoutIfNeeded()
            self.tblTopNodeList.layoutIfNeeded()
            self.viewTop.layoutIfNeeded()
        }
        else if position == POSITION.BOTTOM {
            
            if textviewHeight > 0 {
                let screenHeight = (self.viewBottom.frame.height * 0.6)
                
                if tblBottomNodeList.contentSize.height >= screenHeight{
                    self.tblBottomNodeList.reloadData()
                    self.tblNodeBottomHeightConstraint.constant = screenHeight
                    
                }
                else{
                    //self.tblNodeBottomHeightConstraint.constant = 220.0
                    self.tblBottomNodeList.reloadData()
                    self.tblNodeBottomHeightConstraint.constant = tblBottomNodeList.contentSize.height
                }
                
                
                self.tblTopNodeList.layoutIfNeeded()
                webViewBottomHeightConstraint.constant = (self.viewBottom.frame.height - self.tblBottomNodeList.frame.height)
            }
            else{
                
                //if no description and only nodes
                webViewBottomHeightConstraint.constant = 5
                self.tblBottomNodeList.reloadData()
                self.tblNodeBottomHeightConstraint.constant = self.tblBottomNodeList.contentSize.height
                self.tblTopNodeList.layoutIfNeeded()
                
              
            }
            
            
           // self.txtViewTopDescription.layoutIfNeeded()
        }
        
    }
    
    
    //MARK:- Search

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var nsString : NSString
        if textField == txtTopSearch{
            nsString = txtTopSearch.text as NSString? ?? ""
        }
        else{
             nsString = txtBottomSearch.text as NSString? ?? ""
        }
        
        let newString = nsString.replacingCharacters(in: range, with: string)
        self.filterContent(for: newString)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
  
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        self.isSearching = false
        self.tblTopNodeList.reloadData()
        self.tblBottomNodeList.reloadData()
        return false
    }
  
    
    func filterContent(for searchText: String) {
        
        if searchText.count > 0{
            let predicate = NSPredicate(format: "SELF.title contains[c] %@", searchText)
            searchResults = arrAllNodes.filter { predicate.evaluate(with: $0) }
            print("---------------------------- \(searchResults.count)")
            self.isSearching = true
            var arrCatName = [[String:Any]]()
            var arrSecond = [[String: Any]]()
            arrSections = [String: Any]()
            for data in searchResults {
                if data["catId"] as! Int == 1{
                    arrCatName.append(data)
                    arrSections[data["catName"] as! String] = arrCatName
                }
                else{
                    if(!Array(arrSections.keys).contains(data["catName"] as! String)) {
                        arrSecond.removeAll()
                    }
                    //                    arrCatName.removeAll()
                    arrSecond.append(data)
                    arrSections[data["catName"] as! String] = arrSecond
                    
                    
                    //                    arrSections.append(Category(name: "OTHERS", items: arrCatName))
                    
                }
            }
            
            
            
            
            self.tblTopNodeList.reloadData()
            self.tblBottomNodeList.reloadData()
        }
        else{
            self.isSearching = false
            var arrCatName = [[String:Any]]()
            var arrSecond = [[String: Any]]()
            arrSections = [String: Any]()
            for data in arrAllNodes {
                
                if data["catId"] as! Int == 1{
                    arrCatName.append(data)
                    arrSections[data["catName"] as! String] = arrCatName
                }
                else{
                    if(!Array(arrSections.keys).contains(data["catName"] as! String)) {
                        arrSecond.removeAll()
                    }
                    //                    arrCatName.removeAll()
                    arrSecond.append(data)
                    arrSections[data["catName"] as! String] = arrSecond
                    
                    
                    //                    arrSections.append(Category(name: "OTHERS", items: arrCatName))
                    
                }
            }

            self.tblTopNodeList.reloadData()
            self.tblBottomNodeList.reloadData()
        }
        
    }
    
   
    
    
    //MARK:- Tableview Datasource & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("count is \(arrSections.count)")
        return self.arrSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(self.arrSections.keys)[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let items = Array(self.arrSections.values)[section]
        return (items as! [AnyObject]).count
        
//        if isSearching {
//          return  searchResults.count
//        }
//        else{
//          return  arrAllNodes.count
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Array(self.arrSections.keys)[section].lowercased() == "none" {
            return 0.0
        }else {
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.font  = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.numberOfLines = 0
        
         let items = Array(self.arrSections.values)[indexPath.section]
        let item = (items as! [AnyObject])[indexPath.row]
        let itemValue = item as! [String: Any]
        print("item is \(item)")
        print(itemValue["title"] as? String ?? "")
        cell.detailTextLabel?.text = itemValue["title"] as? String ?? ""
        if let strStep = itemValue["title"] as? String{
            cell.textLabel?.text = strStep
        }
        

      /*  if isSearching {
            cell.detailTextLabel?.text = searchResults[indexPath.row]["title"] as? String
            
            if let strStep = searchResults[indexPath.row]["cmsheaderTitle"] as? String{
                cell.textLabel?.text = strStep
            }
            else {
                cell.textLabel?.text = ""
            }
            
            
            if (searchResults[indexPath.row]["description"] != nil  || searchResults[indexPath.row]["file"] != nil){
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else{
                cell.accessoryType = .none
            }
        }
        else{
            cell.detailTextLabel?.text = arrAllNodes[indexPath.row]["title"] as? String
            if let strStep = arrAllNodes[indexPath.row]["cmsheaderTitle"] as? String{
                cell.textLabel?.text = strStep
            }
            
            
            if (arrAllNodes[indexPath.row]["description"] != nil  || arrAllNodes[indexPath.row]["file"] != nil){
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else{
                cell.accessoryType = .none
            }
        }
    */
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var strCmsId : Int
        let items = Array(self.arrSections.values)[indexPath.section]
        let item = (items as! [AnyObject])[indexPath.row]
        let itemValue = item as! [String: Any]
        if isSearching {
            strCmsId = (itemValue["id"] as? Int)!
        }
        else{
            print("selected id \(String(describing: itemValue["id"] ?? ""))")
            
            strCmsId =  (itemValue["id"] as? Int)!
        }
        
        if let cmsId : Int  = strCmsId {
            let cmsVC : CMSListViewController = self.storyboard?.instantiateViewController(withIdentifier: "CMSListViewController") as! CMSListViewController
            cmsVC.deepLinkId = cmsId
            self.navigationController?.pushViewController(cmsVC, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

   
     //MARK:- SetPDF in Weview
    func setPDF (_ file : String , isLocal : Bool) -> Void {
        /*
        webViewPDF = WKWebView()
        webViewPDF.uiDelegate = self
        webViewPDF.navigationDelegate = self
        webViewPDF.backgroundColor = UIColor.white
        */
        webViewPDF = UIWebView()
        webViewPDF.delegate = self
        webViewPDF.backgroundColor = UIColor.white
        webViewPDF.scalesPageToFit = true

        let escapedString = file.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)

        let url = URL(string:escapedString ?? "")!
        strUrlForPDF = file
        if isLocal{
           // webViewPDF.loadFileURL(url, allowingReadAccessTo: url)
            webViewPDF.loadRequest(NSURLRequest(url: url) as URLRequest)
        }
        else{
            //webViewPDF.load(URLRequest(url: url))
            webViewPDF.loadRequest(NSURLRequest(url: url) as URLRequest)
        }
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        var height : CGFloat = 0.0
        //iphone 5,6,7,8
        if (UIApplication.shared.statusBarFrame.size.height == 20){
             height = self.viewPDF.frame.height - (self.txtViewPDFHeaderHeightConstraint.constant + self.txtViewPDFFooterHeightConstraint.constant) - (topBarHeight + 0)
        }
        else{
             height = self.viewPDF.frame.height - (self.txtViewPDFHeaderHeightConstraint.constant + self.txtViewPDFFooterHeightConstraint.constant) - (topBarHeight + 30)
        }
        webViewPDF.frame  = CGRect(x: 0, y: self.txtViewPDFHeader.frame.height, width:self.viewPDF.frame.width, height:height)
        self.viewPDF.addSubview(webViewPDF)
//        self.viewPDF.bringSubviewToFront(self.btnExpand)
    }
    
    @IBAction func btnPDFExpand(_ sender: UIButton) {
   
        if  sender.isSelected{
            self.viewExpand.isHidden = true
            self.btnExpand.frame.origin.y = self.txtViewPDFHeader.frame.height
        }
        else{
            if ((AppDelegate.sharedInstance()?.reachable())!){
                self.setPDFForExpandView(strUrlForPDF, isLocal: false)
            }
            else{
                self.setPDFForExpandView(strUrlForPDF, isLocal: true)
            }
            self.btnExpand.frame.origin.y = self.viewExpand.frame.origin.y
            self.viewExpand.isHidden = false
//            self.viewPDF.bringSubviewToFront(self.viewExpand)
        }
//        self.viewPDF.bringSubviewToFront(self.btnExpand)
        sender.isSelected = !sender.isSelected
        
        
    }
    
    func setPDFForExpandView (_ file : String , isLocal : Bool) -> Void {
        /*
        webViewExpand = WKWebView()
        webViewExpand.uiDelegate = self
        webViewExpand.navigationDelegate = self
        webViewExpand.backgroundColor = UIColor.white
         */
        webViewExpand = UIWebView()
        webViewExpand.delegate = self
        webViewExpand.backgroundColor = UIColor.white
        webViewExpand.scalesPageToFit = true
        
        let escapedString = file.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)

        let url = URL(string:escapedString ?? "")!
        if isLocal{
            webViewExpand.loadRequest(NSURLRequest(url: url) as URLRequest)
            //webViewExpand.loadFileURL(url, allowingReadAccessTo: url)
        }
        else{
            webViewExpand.loadRequest(NSURLRequest(url: url) as URLRequest)
            //webViewExpand.load(URLRequest(url: url))
        }
       
        webViewExpand.frame  = self.viewExpand.bounds
        self.viewExpand.addSubview(webViewExpand)
        
    }
    
    
    
    //MARK:- SetIMAGE in Weview
    func setImageWithURL (_ url: String,isLocal : Bool){
        /*
        webViewIMAGE = WKWebView()
        webViewIMAGE.uiDelegate = self
        webViewIMAGE.navigationDelegate = self
        webViewIMAGE.backgroundColor = UIColor.white
        */
        
        webViewIMAGE = UIWebView()
        webViewIMAGE.delegate = self
        webViewIMAGE.backgroundColor = UIColor.white
        webViewIMAGE.scalesPageToFit = true
        
        
        //let escapedString = file.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        let url = URL(string:url)!
        if isLocal{
            webViewIMAGE.loadRequest(NSURLRequest(url: url) as URLRequest)
            //webViewIMAGE.loadFileURL(url, allowingReadAccessTo: url)
        }
        else{
            webViewIMAGE.loadRequest(NSURLRequest(url: url) as URLRequest)
           // webViewIMAGE.load(URLRequest(url: url))
        }
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        var height : CGFloat = 0.0
        //iphone 5,6,7,8
        if (UIApplication.shared.statusBarFrame.size.height == 20){
            height = self.viewIMAGE.frame.height - ((self.txtViewImageHeaderHeightConstraint.constant) + self.txtViewImageFooterHeightConstraint.constant) - (topBarHeight + 0)
        }
        else{
            height = self.viewIMAGE.frame.height - (self.txtViewImageHeaderHeightConstraint.constant + self.txtViewImageFooterHeightConstraint.constant) - (topBarHeight + 30)
        }
        webViewIMAGE.frame  = CGRect(x: 0, y: self.txtViewImageHeader.frame.height, width:self.viewIMAGE.frame.width, height:height)
        self.viewIMAGE.addSubview(webViewIMAGE)
        self.view.layoutIfNeeded()
    }
    
    //MARK:- Download Image
    func downloadImages (){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CMS_Image")
        request.returnsObjectsAsFaults = false
        do {
            let result = try AppDelegate.sharedInstance()?.managedObjectContext.fetch(request)
            for data in result as! [NSManagedObject]{
                let strUrl = URL(string: data.value(forKey: "url") as! String)
                if (strUrl != nil) {
                    let fileName : String = (AppDelegate.sharedInstance()?.getImageName(fromURL: strUrl?.absoluteString))!
                    if (!(AppDelegate.sharedInstance()?.imageExist(inDocument: fileName))!){
                        //Create URL to the source file you want to download
                        let fileURL = URL(string: (strUrl?.absoluteString)!)
                        //Create Folder
                        self.createFolderAtDocumentDir()
                        //Download Task
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                // Success
                                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                    //print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                
                                do {
                                    
                                    let destinationPath : URL = URL(fileURLWithPath: ((AppDelegate.sharedInstance()?.getDocumentPath())!))
                                    //try FileManager.default.copyItem(at: tempLocalUrl, to:destinationPath)
                                    try FileManager.default.copyItem(at: tempLocalUrl,
                                                                     to: destinationPath.appendingPathComponent(fileName))
                                    print("Successfully downloaded file : \(fileName)")
                                    
                                } catch (let writeError) {
                                    print("************* Error creating a file *********** : \(writeError)")
                                }
                                
                            } else {
                                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error While Downloading");
                            }
                        }
                        task.resume()
                        
                    }
                    
                }
            }
        }
        catch {
            
            print("Failed while Downloading")
        }
    }
    
    func createFolderAtDocumentDir (){
        let FOLDER_NAME = "CMS_IMAGE"
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("\(FOLDER_NAME)")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            NSLog("Document directory is \(filePath)")
        }
    }
    
}


extension CMSListViewController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        AppDelegate.sharedInstance()?.showProgressAlert("Loading...")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        AppDelegate.sharedInstance()?.hideProgressAlert()
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontFamily =\"-apple-system\"")
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontSize =\"17px\"")

        
        if webView == webViewPDF{
            self.btnExpand.isHidden = false
            self.btnExpand.frame.origin.y = txtViewPDFHeader.contentSize.height
            
        }
        else if webView == webviewTopPosition{
            if let height =  NumberFormatter().number(from :webView.stringByEvaluatingJavaScript(from: "document.body.getBoundingClientRect().height") ?? "0") {
                let contentHeight = CGFloat(truncating: height)
                print("Height : \(contentHeight)")
                if contentHeight == 10.0{
                    self.heightView(0.0, position: POSITION.TOP)
                }
                else{
                    self.heightView(contentHeight, position: POSITION.TOP)
                }
                
                self.webviewTopPosition.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
        else if webView == webviewBottomPosition{
            if let height =  NumberFormatter().number(from :webView.stringByEvaluatingJavaScript(from: "document.body.getBoundingClientRect().height") ?? "0") {
                let contentHeight = CGFloat(truncating: height)
                if contentHeight == 10.0{
                    self.heightView(0.0, position: POSITION.BOTTOM)
                }
                else{
                    self.heightView(contentHeight, position: POSITION.BOTTOM)
                }
                
                self.webviewBottomPosition.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
       
    }
    
//    private func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
//        if navigationType == .linkClicked{
//            if let url = request.url {
//                let safariVC = SFSafariViewController(url: url)
//                self.present(safariVC, animated: true, completion: nil)
//                safariVC.delegate = self
//                
//                if #available(iOS 10.0, *) {
//                    safariVC.preferredBarTintColor = UIColor.init(red: 0.92, green: 0.98, blue: 1.0, alpha: 0.7)
//                    safariVC.preferredControlTintColor = UIColor.init(hexFromString: "3890D2")
//                } else{
//                    safariVC.view.tintColor = UIColor.init(red: 0.92, green: 0.98, blue: 1.0, alpha: 0.7)
//                }
//
//                return false
//            }
//        }
//        
//        return true
//    }
}

extension String {
//    var htmlToAttributedString: NSAttributedString? {
//        guard let data = data(using: .utf8) else { return NSAttributedString() }
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return NSAttributedString()
//        }
//    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
}


extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
extension UIBarButtonItem {
    
    var isHidden: Bool {
        get {
            return tintColor == .clear
        }
        set {
            tintColor = newValue ? .clear : .blue //or whatever color you want
            isEnabled = !newValue
            isAccessibilityElement = !newValue
        }
    }
    
}

extension UITextField {
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcon(_ icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
}



