//
//  UserProfile.swift
//  WorldMedicalCard
//
//  Created by Abhishek Chatterjee on 07/02/22.
//

import Foundation

struct UserProfile: Codable {
    enum Gender: String, Codable {
        case Male, Female
    }
    
    enum CardOrderStatus: Codable {
        case UnRegistered
        case Registered
        case Failed
        case Completed
         
    }
    var firstName: String?
    var lastName: String?
    var memberSince: String?
    var avatar: String?
    var birthDate: String?
    var gender: Gender?
    var organDonation: Bool?
    var ssn: String?
    var nationality: String?
    var phone: String?
    var otherInfo: String?
    var isActiveSubscription: Bool?
    var isForcedRefreshToken: Bool?
    var onBoardingRequired: Bool?
    var postalAddress: PostalAddress?
    var insurance: Insurance?
    var emergencyContact: [EmergencyContact?]?
    private let cardOrderStatus: String?
    private let cardOrderDate: String?
    
    
    init?(form: Form) {
        // required field
        guard let firstName = form["firstName"], !firstName.isEmpty,
              let lastName = form["lastName"], !lastName.isEmpty,
              let gender = form.formValue(key: "gender") as? Gender,
              let birthDate = UserDefaults.standard.string(forKey: Constants.UserDefaults_Key_DOB),
              let nationality = form["nationality"], !nationality.isEmpty,
              let phone = form["contactInfo"], !phone.isEmpty else {
            return nil
        }
              
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.nationality = nationality
        self.phone = phone

        organDonation = form.formValue(key: "organDoner") as? Bool
        ssn = form["ssn"].isEmptyValue ? nil : form["ssn"]
        postalAddress = PostalAddress(form: form) ?? nil
        insurance = Insurance(form: form) ?? nil
        emergencyContact = [EmergencyContact(firstContact: form), EmergencyContact(secondContact: form)]
        cardOrderDate = nil
        cardOrderStatus = nil
    }
    
    //Card order status
    var orderStatus: CardOrderStatus {
        switch cardOrderStatus {
            case "Registered":
                return .Registered
            case "Failed":
                return .Failed
            case "Completed":
                return .Completed
            default:
                return .UnRegistered
        }
    }
    
    var reorderCardAvailableInDays: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        guard let d = cardOrderDate, let cardOrderDate = dateFormatter.date(from: d),
              let oneYear = Calendar.current.date(byAdding: .year, value: 1, to: cardOrderDate) else {
            return nil
        }
        
        let now = Date()
        
        if let remainDays = Calendar.current.dateComponents([.day], from: now, to: oneYear).day {
            return max(remainDays, 0)
        }
        
        return nil
    }
    
    var fullName: String? {
        switch (firstName, lastName) {
            case (nil, let lastName):
                return lastName
            case (let firstName, nil):
                return firstName
            case (.some(let firstName), .some(let lastName)):
                return firstName + " " + lastName
        }
    }
    
    var nameInitials: String? {
        switch (firstName, lastName) {
            case (nil, let lastName):
                return lastName?.prefix(1).capitalized
            case (let firstName, nil):
                return firstName?.prefix(1).capitalized
            case (.some(let firstName), .some(let lastName)):
                return firstName.prefix(1).capitalized + " " + lastName.prefix(1).capitalized
        }
    }
    
    var memberSinceDate: Date? {
        guard let memberSince = memberSince else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: memberSince)
    }
    
    var dob: Date? {
        guard let dob = birthDate else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: dob)
    }
    var isProfileComplete: Bool {
        return (fullName != nil) || (birthDate != nil) || (gender != nil) || (nationality != nil) || (phone != nil)
    }
    func firebaseFirstName(_ displayName: String?) -> String {
        guard let value = displayName else {
            return ""
        }
        let nameArr = value.components(separatedBy: " ")
        return nameArr[0]
    }
    func firebaseLastName(_ displayName: String?) -> String {
        guard let value = displayName else {
            return ""
        }
        let nameArr = value.components(separatedBy: " ")
        return nameArr[1]
    }
    
    /// Whether the user information are provided to order a card
    /// * firstname
    /// * lastname
    /// * birthday
    /// * gender
    /// * nationality
    /// * phone
    /// * at least one emergency contact
    func isValidToOrderCard() -> Bool {
        
        guard !firstName.isEmptyValue,
              !firstName.isEmptyValue,
              self.dob != nil,
              self.gender != nil,
              !nationality.isEmptyValue,
              !phone.isEmptyValue else {
            return false
        }
        
        let emergency = (emergencyContact ?? []).compactMap { $0 }
        
        return !emergency.isEmpty
    }
}

class PostalAddress: Codable {
    var info: String?
    var city: String?
    var zipCode: String?
    var country: String?
    
    init?(form: Form) {
        if (form["address"].isEmptyValue) &&
            (form["city"].isEmptyValue) &&
            (form["zip"].isEmptyValue) &&
            (form["country"].isEmptyValue) {
            return nil
        } else {
            self.info = form["address"]
            self.city = form["city"]
            self.zipCode = form["zip"]
            self.country = form["country"]
        }
    }
}

struct Insurance: Codable {
    enum InsuranceType: String, Codable {
        case Travel, Health
    }
    
    var company: String?
    var type: InsuranceType?
    var phone: String?
    var policy: String?
    
    init?(form: Form) {
        if (form["company"].isEmptyValue),
           form.formValue(key: "type") == nil,
           (form["phone"].isEmptyValue) &&
            (form["policy"].isEmptyValue) {
            return nil
        } else {
            company = form["company"]
            type = form.formValue(key: "type") as? InsuranceType
            phone = form["phone"]
            policy = form["policy"]
        }
    }
}

struct EmergencyContact: Codable {
    var name: String?
    var phone: String?
    var relationship: String?
    
    init?(firstContact form: Form) {
        if (form["contactName1"].isEmptyValue) &&
            (form["contactPhone1"].isEmptyValue) &&
            (form["relationship1"].isEmptyValue) {
            return nil
        } else {
            name = form["contactName1"]
            phone = form["contactPhone1"]
            relationship = form["relationship1"]
        }
    }
    init?(secondContact form: Form) {
        if (form["contactName2"].isEmptyValue) &&
            (form["contactPhone2"].isEmptyValue) &&
            (form["relationship2"].isEmptyValue) {
            return nil
        } else {
            name = form["contactName2"]
            phone = form["contactPhone2"]
            relationship = form["relationship2"]
        }
    }
}
