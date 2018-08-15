//
//  UserDisplaySupport.swift
//  PublicService
//
//  Created by T33Developer01 on 22/09/17.
//  Copyright © 2017 Perkins Coie. All rights reserved.
//

import Foundation



public class DETAIL {
    public var general_info : general_info?
    public var a_stats : Array<a_stats>?
    public var pHoto_Id:String?
    public class func modelsFromDictionaryArray(array:NSArray) -> [DETAIL]
    {
        var models:[DETAIL] = []
        for item in array
        {
            models.append(DETAIL(dictionary: item as! NSDictionary)!)
        }
        return models
    }

       required public init?(dictionary: NSDictionary) {

        if (dictionary["general_info"] != nil) { general_info = general_info(dictionary: dictionary["general_info"] as! NSDictionary)}
        if (dictionary["a_stats"] != nil) { a_stats = a_stats.modelsFromDictionaryArray(array: dictionary["a_stats"] as! NSArray) }
        if (dictionary["PHOTO_ID"] != nil) { pHoto_Id = dictionary["PHOTO_ID"] as? String}

    }




    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.general_info?.dictionaryRepresentation(), forKey: "general_info")

        return dictionary
    }

    func basicInfoPageDataSource()->DDCPage{
     let ddcPage = DDCPage(title:NSLocalizedString("Public Service Detail", comment: ""))
     if let section = self.immutinization() {ddcPage.sections.append(section)}
     if let section = self.cardSummary(){ddcPage.sections.append(section)}
     if let section = self.returnAnimalStatistics(){ddcPage.sections.append(section)}

     return ddcPage

    }
    func animalStatisticsPage()->DDCPage{
     let ddcPage = DDCPage(title:NSLocalizedString("ANIMAL STATISTICS", comment: ""))
     if let section = self.cardSummary(){ddcPage.sections.append(section)}
     return ddcPage

    }
    func returnAnimalStatistics()->DSection?{
        var title:String? = nil
        let local = 1
        if a_stats != nil{title = NSLocalizedString("Type: ", comment: "") + "\(general_info)"}
        let section = DSection(title:NSLocalizedString("HEALTHCARD SUMMARY", comment: ""))
        section.value = self
        if local == 1{
               let attribute = DDCAttribute.init(title: NSLocalizedString("ANIMAL STATISTICS", comment: ""),
                                                    value: "ANIMAL STATISTICS",
                                                    cell: CellIdentifiers.selectDetailCell,
                                                    displayString: "ANIMAL STATISTICS",
                                                    icon : "form_date")
            section.attributes.append(attribute)}
        if local == 1{
              let attribute = DDCAttribute.init(title: NSLocalizedString("ATTACHMENT", comment: ""),
                                                    value: "ATTACHMENT",
                                                    cell: CellIdentifiers.selectDetailCell,
                                                    displayString: "ATTACHMENT",
                                                    icon : "form_date")
            section.attributes.append(attribute)}
            //}

    return section
    }


    func cardSummary()->DSection?{
        var title:String? = nil

        if a_stats != nil{title = NSLocalizedString("Type: ", comment: "")}
        let section = DSection(title:NSLocalizedString("HEALTHCARD SUMMARY", comment: ""))
        section.value = self

        for  each in a_stats! {

            if each.iD != nil{
                let attribute = DDCAttribute.init(title: NSLocalizedString("ID", comment: ""),
                                                   value: each.iD,
                                                   cell: CellIdentifiers.detail,
                                                   displayString: "\(each.iD)",
                                                   icon : "form_date")
                                                   section.attributes.append(attribute)
                              }
            if each.nAME != nil{
                let attribute = DDCAttribute.init(title: NSLocalizedString("NAME", comment: ""),
                                                  value: each.nAME,
                                                  cell: CellIdentifiers.detail,
                                                  displayString: "\(each.nAME)",
                    icon : "form_date")
                  section.attributes.append(attribute)
            }
            if each.cOUNT != nil{
                let attribute = DDCAttribute.init(title: NSLocalizedString("COUNT", comment: ""),
                                                  value: each.cOUNT,
                                                  cell: CellIdentifiers.detail,
                                                  displayString: "\(each.cOUNT)",
                    icon : "form_date")
                section.attributes.append(attribute)
             }

             }
            if section.attributes.count == 0 {return nil}

            return section
        }

    func immutinization() -> DSection? {
       // let requestForImmutizationPage = self.basicInfoPageDataSource()
        var title:String? = nil
        //if general_info != nil {title = NSLocalizedString("Type: ", comment: "") + "\(general_info)"}
        let section = DSection(title:NSLocalizedString("REQUEST FOR AN APPOINTMENT FOR IMMUNIZATION", comment: ""))
        section.value = self
        let local = "\(general_info?.cREATED_DATE)"


        if general_info?.cREATED_DATE != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Date of Request", comment: ""),
                                              value: local,
                                              cell: CellIdentifiers.detail,
                                              displayString: "\(general_info?.cREATED_DATE)",
                                              icon : "form_date")
                                              section.attributes.append(attribute)
        }
        if general_info?.tRANSFER_OFFICE_TITLE != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Transfer To", comment: ""),
                                              value: general_info?.tRANSFER_OFFICE_TITLE!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.tRANSFER_OFFICE_TITLE)",
                                              icon : "cell_transporter")
            section.attributes.append(attribute)
        }
        if general_info?.sTATUS != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Status", comment: ""),
                                              value: general_info?.sTATUS!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.sTATUS)",
                                              icon : "form_status")
            section.attributes.append(attribute)
        }
        if general_info?.nAME != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Name", comment: ""),
                                              value: general_info?.nAME!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.nAME)",
                                              icon : "form_national-ID")
            section.attributes.append(attribute)
        }
        if general_info?.nATIONAL_ID != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("National id", comment: ""),
                                              value: general_info?.nATIONAL_ID!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.nATIONAL_ID)",
                                               icon : "form_national-ID")
            section.attributes.append(attribute)
        }
        if general_info?.pHONE_NUMBER != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Phone number", comment: ""),
                                              value: general_info?.pHONE_NUMBER!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.pHONE_NUMBER)",
                                              icon : "cell_big-call")
            section.attributes.append(attribute)
        }
        if general_info?.eMAIL != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Email", comment: ""),
                                              value: general_info?.eMAIL!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.eMAIL)",
                                                icon : "form_email")
            section.attributes.append(attribute)
        }
        if general_info?.hEALTHCARD_NUMBER != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Health Card Number", comment: ""),
                                              value: general_info?.hEALTHCARD_NUMBER!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.hEALTHCARD_NUMBER)",
                                             icon : "form_healthcard")
            section.attributes.append(attribute)
        }
        if general_info?.nOTE != nil {
            let attribute = DDCAttribute.init(title: NSLocalizedString("Notes", comment: ""),
                                              value: general_info?.nOTE!,
                                              cell: CellIdentifiers.detail,
                                              displayString:"\(general_info?.nOTE)",
                                                icon : "form_notes")
            section.attributes.append(attribute)
        }


        //..
        if section.attributes.count == 0 {return nil}

        return section
    }


}

public class general_info {
    public var rEQUEST_ID : Int?
    public var sERVICE_TYPE : Int?
    public var sERVICE_REQUEST_NAME : String?
    public var cREATED_DATE : Int?
    public var sERVICE_REQUEST_NUMBER : Int?
    public var sTATUS : String?
    public var tRANSFER_OFFICE : Int?
    public var tRANSFER_OFFICE_TITLE : String?
    public var nAME : String?
    public var nATIONAL_ID : Int?
    public var pHONE_NUMBER : Int?
    public var eMAIL : String?
    public var hEALTHCARD_NUMBER : String?
    public var nOTE : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let general_info_list = general_info.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of general_info Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [general_info]
    {
        var models:[general_info] = []
        for item in array
        {
            models.append(general_info(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let general_info = general_info(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: general_info Instance.
     */
    required public init?(dictionary: NSDictionary) {

        rEQUEST_ID = dictionary["REQUEST_ID"] as? Int
        sERVICE_TYPE = dictionary["SERVICE_TYPE"] as? Int
        sERVICE_REQUEST_NAME = dictionary["SERVICE_REQUEST_NAME"] as? String
        cREATED_DATE = dictionary["CREATED_DATE"] as? Int
        sERVICE_REQUEST_NUMBER = dictionary["SERVICE_REQUEST_NUMBER"] as? Int
        sTATUS = dictionary["STATUS"] as? String
        tRANSFER_OFFICE = dictionary["TRANSFER_OFFICE"] as? Int
        tRANSFER_OFFICE_TITLE = dictionary["TRANSFER_OFFICE_TITLE"] as? String
        nAME = dictionary["NAME"] as? String
        nATIONAL_ID = dictionary["NATIONAL_ID"] as? Int
        pHONE_NUMBER = dictionary["PHONE_NUMBER"] as? Int
        eMAIL = dictionary["EMAIL"] as? String
        hEALTHCARD_NUMBER = dictionary["HEALTHCARD_NUMBER"] as? String
        nOTE = dictionary["NOTE"] as? String
    }



    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.rEQUEST_ID, forKey: "REQUEST_ID")
        dictionary.setValue(self.sERVICE_TYPE, forKey: "SERVICE_TYPE")
        dictionary.setValue(self.sERVICE_REQUEST_NAME, forKey: "SERVICE_REQUEST_NAME")
        dictionary.setValue(self.cREATED_DATE, forKey: "CREATED_DATE")
        dictionary.setValue(self.sERVICE_REQUEST_NUMBER, forKey: "SERVICE_REQUEST_NUMBER")
        dictionary.setValue(self.sTATUS, forKey: "STATUS")
        dictionary.setValue(self.tRANSFER_OFFICE, forKey: "TRANSFER_OFFICE")
        dictionary.setValue(self.tRANSFER_OFFICE_TITLE, forKey: "TRANSFER_OFFICE_TITLE")
        dictionary.setValue(self.nAME, forKey: "NAME")
        dictionary.setValue(self.nATIONAL_ID, forKey: "NATIONAL_ID")
        dictionary.setValue(self.pHONE_NUMBER, forKey: "PHONE_NUMBER")
        dictionary.setValue(self.eMAIL, forKey: "EMAIL")
        dictionary.setValue(self.hEALTHCARD_NUMBER, forKey: "HEALTHCARD_NUMBER")
        dictionary.setValue(self.nOTE, forKey: "NOTE")

        return dictionary
    }

}
public class a_stats {
    public var iD : String?
    public var cOUNT : String?
    public var nAME : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let a_stats_list = a_stats.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of a_stats Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [a_stats]
    {
        var models:[a_stats] = []
        for item in array
        {
            models.append(a_stats(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let a_stats = a_stats(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: a_stats Instance.
     */
    required public init?(dictionary: NSDictionary) {

        iD = dictionary["ID"] as? String
        cOUNT = dictionary["COUNT"] as? String
        nAME = dictionary["NAME"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.iD, forKey: "ID")
        dictionary.setValue(self.cOUNT, forKey: "COUNT")
        dictionary.setValue(self.nAME, forKey: "NAME")

        return dictionary
    }

}
