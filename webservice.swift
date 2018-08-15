

import Foundation
import Alamofire
import SystemConfiguration
import SVProgressHUD

struct WSURL {
    //DEVELOPMENT
    //static let serverPath = "http://arsportal.com/development/api/"
    //static let serverPath = "http://52.42.108.78/development/api/"
    static let serverPath = "http://54.145.209.142/mobile/api/"//Staging Development

    //STAGING
    //static let serverPath = "http://54.145.209.142/ARS/api/"

    //LIVE
    //static let serverPath = "http://arsportal.com/ARS/api/"

    //NEW LIVE
    //static let serverPath = "http://anaam.mewa.gov.sa/anaam/api/"

    //NOTIFICATION
    static let notificationCount = "\(WSURL.serverPath)notificationCount"
    static let readNotification = "\(WSURL.serverPath)readNotification"
    static let getAllNotifications = "\(WSURL.serverPath)getAllNotifications"

    //OTHER
    static let meta = "\(WSURL.serverPath)psMetaData"
    static let labMeta = "\(WSURL.serverPath)labMetaData"
    static let uploadImage = "\(WSURL.serverPath)uploadImage"
    static let fileUpload = "\(WSURL.serverPath)fileUpload"
    static let psfileUpload = "\(WSURL.serverPath)psfileUpload"
    static let getRegionList = "\(WSURL.serverPath)getRegionList"
    static let getOfficeList = "\(WSURL.serverPath)getOfficeList"
    static let getStatistics = "\(WSURL.serverPath)getStatistics"

    //MARK: Authentication
    static let register = "\(WSURL.serverPath)psRegistration"
    static let login = "\(WSURL.serverPath)pslogin"
    static let logout = "\(WSURL.serverPath)pslogout"
    static let changePassword = "\(WSURL.serverPath)psChangePassword"
    static let changePhoneNumber = "\(WSURL.serverPath)psChangePhoneNumber"
    static let forgetPassword = "\(WSURL.serverPath)psForgotPassword"
    static let updatePushToken = "\(WSURL.serverPath)updatePushToken"
    static let verifyRegistration = "\(WSURL.serverPath)psVerifyRegistration"
    static let verifyPhoneNumber = "\(WSURL.serverPath)psVerifyPhoneNumber"

	//add forms
	static let addPublicService = "\(WSURL.serverPath)psAddPublicService"
    static let addImportRequest = "\(WSURL.serverPath)psAddImportRequest"

    //display public service
    static let filterPublicServiceRequest = "\(WSURL.serverPath)filterPublicServiceRequest"
    static let psServiceRequestDetail = "\(WSURL.serverPath)psServiceRequestDetail"
    //display import request
    static let psFilterImportRequest = "\(WSURL.serverPath)psFilterImportRequest"
    static let psImportRequestDetail  = "\(WSURL.serverPath)psImportRequestDetail"
    //display animalist
    static let psAnimalList  = "\(WSURL.serverPath)psAnimalList"
}

//MARK:-
class Stats {
    //Network status support
    public static func networkConnection() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })else {return false}

        ///
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {return false}

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

//MARK:-
@objc protocol WSSupportDelegate {
    func finished(succes:Bool, and data : Any?, message:String)
    @objc optional func uploaded(succes:Bool, and data : Any?, message:String)
}

class WSSupport : NSObject {
    var retryCounter  = 0

    var delegate : WSSupportDelegate!
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }

    init(delegate: WSSupportDelegate) {
        super.init()
        self.retryCounter = 0
        self.delegate = delegate
    }

    func wsDataRequest(url:String, parameters:Dictionary<String, Any>) {
        debugPrint("Request:", url, parameters as NSDictionary, separator: "\n")

        //check for internete collection, if not availabale, don;t move forword
        if Stats.networkConnection() == false {SVProgressHUD.showError(withStatus: NSLocalizedString("No Network available! Please check your connection and try again later.", comment: "")); return}


        //..
        self.request = Alamofire.request(url, method: .post, parameters: parameters)
        if let request = self.request as? DataRequest {
            request.responseString { response in
                var serialzedContent : Any? = nil
                var message = NSLocalizedString("Success!", comment: "")//MUST BE CHANGED TO RELEVANT RESPONSES

                //print("R Data, Exp JSON Strign:", String.init(data: response.data!, encoding: .utf8)!)
                //check content availability and produce serializable response
                if response.result.isSuccess == true {
                    do {
                     var string = String.init(data: response.data!, encoding: .utf8) as String!
                      //p_R Data, Exp JSON Strign:", String.init(data: response.data!, encoding: .utf8)!)
                        serialzedContent = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        //print(serialzedContent as! NSDictionary)
                        debugPrint(message, "Response Dictionary:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                    }catch{
                        message = NSLocalizedString("Webservice Response error!", comment: "")
                        var string = String.init(data: response.data!, encoding: .utf8) as String!

                        //
                        do {
                            if let index = string?.characters.index(of: "{") {
                                if let s = string?.substring(from: index) {
                                    if let data = s.data(using: String.Encoding.utf8) {
                                        serialzedContent = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                                        debugPrint(message, "Courtesy SUME:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                                    }
                                }
                            }
                        }catch{debugPrint(message, error.localizedDescription, "Respone String:", string ?? "No respone value.", separator: "\n")}

                        //let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
                        debugPrint(message, error.localizedDescription, "Respone String:", string ?? "No respone value.", separator: "\n")
                    }

                    //call finised response in all cases
                    self.delegate?.finished(succes: response.result.isSuccess, and: serialzedContent, message: message)

                    //To cache data
                   /* if isDetailCall == true {
                        let wd = WebData.init(url: url, params: parameters, response:serialzedContent ?? "")
                        WebCacheManager.shared.set(webData: wd, forKey: url)
                    }*/
                } else {
                    if self.retryCounter < 1 {//this happens really frequntly so in that case this fn being called again as a retry
                        self.wsDataRequest(url: url, parameters: parameters)
                    }else{
                        message = response.error?.localizedDescription ?? (NSLocalizedString("No network", comment: "")+"!")
                        SVProgressHUD.showError(withStatus: message);//this will show errror and hide Hud
                        debugPrint(message)

                        //call finised response in all cases
                        self.delay(2.0, closure: {self.delegate?.finished(succes: response.result.isSuccess, and: serialzedContent, message:message)})
                    }
                    self.retryCounter += 1
                }
            }
        }
    }

    func serverCompatibility(image:UIImage) -> Data? {
        var imageData:Data!
        var compressionFactor : CGFloat = 1.0
        repeat {
            if let data = UIImageJPEGRepresentation(image, compressionFactor) {
                imageData = data
            }
            compressionFactor = compressionFactor - 0.05
        }while(imageData.count > 500*1024 || compressionFactor > 0.05)
        return imageData
    }

    func uploadImage(url:String, parameters:Dictionary<String, Any>, images:[UIImage])  {
        let URL = url
        //print (URL, parameters)

        //show uploading
        SVProgressHUD.show(withStatus: NSLocalizedString("Uploading Image..", comment: ""))
        SVProgressHUD.setDefaultMaskType(.none)
        Alamofire.upload(multipartFormData: { multipartFormData in
            for image_ in images {
                if let imageData = self.serverCompatibility(image: image_) {
                    //print("final Image size = ", imageData)
                    multipartFormData.append((imageData), withName: "userfile[]", fileName: "file.jpg", mimeType: "image/jpg")
                }
            }

            for (key, value) in parameters {
                let val = String(describing: value)
                multipartFormData.append((val.data(using: .utf8))!, withName: key)
            }

        }, to: URL, method: .post, headers: ["Authorization" : "auth_token"],
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.response { [weak self] response in
                    guard self != nil else {
                        debugPrint("Self does not have the authority here!")
                        return
                    }

                    var serialzedContent : Any? = nil
                    var message = NSLocalizedString("Success!", comment: "")//MUST BE CHANGED TO RELEVANT RESPONSES
                    var success:Bool!

                    //check content availability and produce serializable response
                    do {
                        serialzedContent = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        debugPrint(message, "Response Dictionary:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                        success = true
                    }catch{
                        message = NSLocalizedString("Webservice Response error!", comment: "")
                        let string = String.init(data: response.data!, encoding: .utf8) as String!
                        success = false

                        do {
                            if let s = string?.substring(from: (string?.characters.index(of: "{")!)!) {
                                if let data = s.data(using: String.Encoding.utf8) {
                                    serialzedContent = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                                    debugPrint(message, "Curtecy None:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                                }
                            }
                        }catch{
                            debugPrint(message, error.localizedDescription, "Respone String:", string ?? "No respone value.", separator: "\n")
                        }
                    }

                    //call finised response in all cases
                    self?.delegate?.uploaded?(succes: success, and: serialzedContent, message: message)
                }
            case .failure(let encodingError):
                debugPrint("Error:\(encodingError)")
                //self.handleImageError()
            }
        })
    }

	func uploadFiles(url:String, parameters:Dictionary<String, Any>, files:[File ])  {
		let URL = url
		print (URL, parameters)

		//show uploading
		SVProgressHUD.show(withStatus: NSLocalizedString("Uploading Files..", comment: ""))
		SVProgressHUD.setDefaultMaskType(.none)
		Alamofire.upload(multipartFormData: { multipartFormData in
			for file in files {
				multipartFormData.append(file.data, withName: "userfiles[]", fileName: file.name, mimeType: file.type.rawValue)
			}

			for (key, value) in parameters {
				let val = String(describing: value)
				multipartFormData.append((val.data(using: .utf8))!, withName: key)
			}
		}, to: URL, method: .post, headers: ["Authorization" : "auth_token"],
		   encodingCompletion: { encodingResult in
			switch encodingResult {
			case .success(let upload, _, _):
				upload.response { [weak self] response in
					guard self != nil else {
						debugPrint("Self does not have the authority here!")
						return
					}

					var serialzedContent : Any? = nil
					var message = NSLocalizedString("Success!", comment: "")//MUST BE CHANGED TO RELEVANT RESPONSES
					var success:Bool!

					//check content availability and produce serializable response
					do {
						serialzedContent = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
						debugPrint(message, "Response Dictionary:", serialzedContent ?? "Data could not be serialized", separator: "\n")
						success = true
					}catch{
						message = NSLocalizedString("Webservice Response error!", comment: "")
						let string = String.init(data: response.data!, encoding: .utf8) as String!
						success = false
						//
						do {
							if let s = string?.substring(from: (string?.characters.index(of: "{")!)!) {
								if let data = s.data(using: String.Encoding.utf8) {
									serialzedContent = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
									debugPrint(message, "Curtecy None:", serialzedContent ?? "Data could not be serialized", separator: "\n")
								}
							}
						}catch{
							debugPrint(message, error.localizedDescription, "Respone String:", string ?? "No respone value.", separator: "\n")
						}
					}

					//call finised response in all cases
					self?.delegate?.uploaded?(succes: success, and: serialzedContent, message: message)
				}
			case .failure(let encodingError):
				debugPrint("Error:\(encodingError)")
			}
		})
	}

    /*func uploadFiles(url:String, parameters:Dictionary<String, Any>, files:[ARSFile])  {
        let URL = url
        //print (URL, parameters)

        //show uploading
        SVProgressHUD.show(withStatus: NSLocalizedString("Uploading Files..", comment: ""))
        SVProgressHUD.setDefaultMaskType(.none)
        Alamofire.upload(multipartFormData: { multipartFormData in
            for file in files {
                multipartFormData.append(file.data, withName: "userfiles[]", fileName: file.name, mimeType: file.type.rawValue)
            }

            for (key, value) in parameters {
                let val = String(describing: value)
                multipartFormData.append((val.data(using: .utf8))!, withName: key)
            }
        }, to: URL, method: .post, headers: ["Authorization" : "auth_token"],
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.response { [weak self] response in
                    guard self != nil else {
                        debugPrint("Self does not have the authority here!")
                        return
                    }

                    var serialzedContent : Any? = nil
                    var message = NSLocalizedString("Success!", comment: "")//MUST BE CHANGED TO RELEVANT RESPONSES
                    var success:Bool!

                    //check content availability and produce serializable response
                    do {
                        serialzedContent = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        debugPrint(message, "Response Dictionary:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                        success = true
                    }catch{
                        message = NSLocalizedString("Webservice Response error!", comment: "")
                        let string = String.init(data: response.data!, encoding: .utf8) as String!
                        success = false
                        //
                        do {
                            if let s = string?.substring(from: (string?.characters.index(of: "{")!)!) {
                                if let data = s.data(using: String.Encoding.utf8) {
                                    serialzedContent = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                                    debugPrint(message, "Curtecy None:", serialzedContent ?? "Data could not be serialized", separator: "\n")
                                }
                            }
                        }catch{
                            debugPrint(message, error.localizedDescription, "Respone String:", string ?? "No respone value.", separator: "\n")
                        }
                    }

                    //call finised response in all cases
                    self?.delegate?.uploaded?(succes: success, and: serialzedContent, message: message)
                }
            case .failure(let encodingError):
                debugPrint("Error:\(encodingError)")
            }
        })
    }*/
}

//MARK:-
enum WSResponseCode : String {
    case success = "1"
    case failure = "2"
}

enum ImageUploadFlag : String {
    case profilePic = "profile_pic"
}

protocol WSManagerDelegate {
    func request(completed formattedData:Any?, with manager:WSManager, success:Bool?, message:String?)
}

class WSManager : NSObject {
    var delegate : WSManagerDelegate!
    var wsSupport : WSSupport!
    var dismissHud : Bool! = true //default set to true
    let stats = Stats()

    func setWSParam(with delegate:WSManagerDelegate? = nil, supportDelegate:WSSupportDelegate?) {
        self.delegate = delegate
        self.wsSupport = WSSupport.init(delegate:supportDelegate!)
    }

    func request(url:String, parameters:Dictionary<String, Any>, hideHud:Bool?, message:String?){
        self.dismissHud = hideHud ?? true

        //show progress hud, if message available (nil show nothing, blank show progress, text show progress with mesage)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        if message != nil{SVProgressHUD.show(withStatus: message)}
        self.wsSupport.wsDataRequest(url: url, parameters: parameters)
    }

    func uploadImages(images:[UIImage],	flag:String!,entityId:String?) {

        //get parameter
        var parameters = self.requiredParameters()
        parameters["flag"] = flag
        if  entityId != nil {parameters["entity_id"] = entityId}

        //request now
        self.wsSupport.uploadImage(url: WSURL.uploadImage, parameters: parameters, images: images)
    }

    func wsError(dictionary : Dictionary<String, Any>!, showAlert:Bool? = true) -> Bool {

        if let meta = dictionary["meta"] as? Dictionary<String, Any> {//considring if dictionary is formed then meta is definitly there
            if let succes = meta["success"]	{
                let successString = String(describing: succes)
                //print("succes:", succes);
                if successString == "1" {return false}//NO Error
                /*if successString == "2" {//I am considering Success Code 2 is always for Logout
                    if self.stats.removeUser() == true {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate!
                        appDelegate?.setExpectedRootView(successString: "2")
                    }
                }*/
                /*if successString == "3"{
                    //for maintenance
                    if self.stats.removeUser() == true {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate!
                        appDelegate?.setExpectedRootView(successString: "3", message: meta["message"] as? String)
                    }
                    return true
                }*/
            }

            //
            if let message = meta["message"] {
                let m = String(describing: message)
                if showAlert == true {SVProgressHUD.showError(withStatus: m)}//show error message
                return true
            }
        }
        return false
    }

    func notificationParameters() -> Dictionary<String, Any> {
        let parameters =  ["office_level":self.stats.user.office.officeLevel,
                           "department":self.stats.user.office.department] as Dictionary<String, Any>
        return parameters
    }

    func requiredParameters() -> Dictionary<String, Any> {
        var parameters =  ["lang":self.stats.meta.selectedLanguage,
                           "device_type":self.stats.meta.deviceType,
                           "device_id":self.stats.meta.deviceId] as Dictionary<String, Any>

        //if user is logged in then
        if self.stats.user?.loggedIn() == true {
            parameters["user_id"] = self.stats.user.userId
            parameters["access_token"] = self.stats.user.accessToken
           // parameters["office"] = self.stats.user.office.officeId
        }
        return parameters
    }

    func requiredQParameters() -> Dictionary<String, Any> {
        var parameters = self.requiredParameters()
        parameters["department"] = self.stats.user.office.department
        parameters["region"] = self.stats.user.office.region
        parameters["office_level"] = self.stats.user.office.officeLevel
        return parameters
    }
}

/*
 fileUpload	POST	"http://52.42.108.78/development/api/fileUpload
 user_id
 office
 hash_token
 entity_id
 uploading_section
 userfiles[]

 "{
	""meta"": {
 ""success"": 1,
 ""lang"": ""en"",
 ""message"": ""File successfully uploaded""
	},
	""file_detail"": {
 ""succeed"": [
 ""0_354.jpg""
 ]
	},
 }"
 */


class  WSFileUploadManager: WSManager, WSSupportDelegate {
	//MARK: Shared Instance
	static let sharedInstance: WSFileUploadManager = WSFileUploadManager()

	private override init() { // can not init is singleton
		//set up super
		super.init()

		self.setWSParam(supportDelegate: self)
	}

	//vaiables
	var uploadStatus = false
	var isUploading : Bool {
		set {
			self.uploadStatus = isUploading
		}
		get {
			if self.uploadStatus == true {SVProgressHUD.showInfo(withStatus: NSLocalizedString("A file upload Queue is in progress, please wait for a while.", comment: ""))}
			return self.uploadStatus
		}
	}

	func uploadFile(files:[File],
	                entityId:String!,
	                section:String) {
		if self.uploadStatus == true {SVProgressHUD.showInfo(withStatus: NSLocalizedString("A file upload Queue is in progress, please wait for a while.", comment: ""))}

		//get parameter
		var parameters = self.requiredParameters()
		parameters["uploading_section"] = section
		parameters["entity_id"] = entityId
        parameters["userfiles"] = files

		//request now
		self.isUploading = true
		self.wsSupport.uploadFiles(url: WSURL.psfileUpload, parameters: parameters, files: files)
	}

	func uploaded(succes: Bool, and data: Any?, message: String) {
		SVProgressHUD.dismiss()
		self.isUploading = false
		if let dictionary = data as? Dictionary<String, Any> {
			if self.wsError(dictionary: dictionary) {return}//nothing left to do

			//
			self.delegate.request(completed: data, with: self, success: true, message: message)
		}
	}

	//not to be used
	internal func finished(succes: Bool, and data: Any?, message: String) {

	}
}
