//
//  ProfileViewController.swift
//  barcodeSuperApp
//
//  Created by Luigi Marrandino on 16/03/18.
//  Copyright © 2018 Luigi Marrandino. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import HealthKit
import HealthKitUI

//let hkStore = HKHealthStore()
let healthKitStore:HKHealthStore = HKHealthStore()

let healthKitActivitySummary = HKActivitySummary()

let healthKitTypesToRead : Set<HKObjectType> = [
    HKSampleType.quantityType(forIdentifier: .height)!,
    HKSampleType.quantityType(forIdentifier: .bodyMass)!,
    HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!,
    HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
    HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
]

let healthKitTypesToWrite: Set<HKSampleType> = [
    HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
    HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
    HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!
]



class ProfileViewController: UIViewController, SideMenuItemContent {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateHeight()
        updateWeight()
        updateSex()
        //birthDate.text = String(getAge())
        
        
        func updateHeight() {
            let heightSample = HKSampleType.quantityType(forIdentifier: .height)
            getMostRecentSample(for: heightSample!, completion: { (sample, error) in
                guard let sample = sample else {
                    if let error = error {
                        print("error")
                    }
                    return
                }
                
                self.height.text = String(sample.quantity.doubleValue(for: HKUnit.meter()))
            })
        }
        
        func updateWeight() {
            let weightSample = HKSampleType.quantityType(forIdentifier: .bodyMass)
            getMostRecentSample(for: weightSample!, completion: { (sample, error) in
                guard let sample = sample else {
                    if let error = error {
                        print("error")
                    }
                    return
                }
                
                self.weight.text = String(sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))
            })
            
        }
        
        func updateSex() {
            let sex = try! healthKitStore.biologicalSex().biologicalSex.rawValue
            switch sex {
            case 1:
                self.sex.text = "Female"
            case 2:
                self.sex.text = "Male"
            default:
                self.sex.text = "BOOOOOH"
            }
        }
        
        func getAge()->Int {
            let date = try! healthKitStore.dateOfBirthComponents()
            let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            var age = today.year! - date.year!
            if today.month! <= date.month! && today.day! < date.day! {
                age -= 1
            }
            
            return age
        }
        
        
        func getMostRecentSample(for sampleType: HKSampleType,
                                 completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
            
            //1. Use HKQuery to load the most recent samples.
            let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                                  end: Date(),
                                                                  options: .strictEndDate)
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                                  ascending: false)
            
            let limit = 1
            
            let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                            predicate: mostRecentPredicate,
                                            limit: limit,
                                            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                                
                                                //2. Always dispatch to the main thread when complete.
                                                DispatchQueue.main.async {
                                                    
                                                    guard let samples = samples,
                                                        let mostRecentSample = samples.first as? HKQuantitySample else {
                                                            
                                                            completion(nil, error)
                                                            return
                                                    }
                                                    
                                                    completion(mostRecentSample, nil)
                                                }
            }
            
            HKHealthStore().execute(sampleQuery)
        }

        
        
        
    }
    
    
    

    
    
    
    
    func requestPermissions(){
        
        if HKHealthStore.isHealthDataAvailable() {
            // add code to use HealthKit here...
            print("Yes, HealthKit is Available")
        } else {
            print("There is a problem accessing HealthKit")
        }
        
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            if success {
                print("success")
            } else {
                print("failed")
            }
        }
    }

    
    
    
    
    
    @IBAction func openMenu(_ sender: Any) {
        showSideMenu()
    }
    
}
