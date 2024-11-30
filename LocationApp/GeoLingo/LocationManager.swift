//
//  LocationManager.swift
//  GeoLingo
//
//  Created by Naomi K on 2024-11-13.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    // Store all locations for CSV saving
    @Published var locationData: [(timestamp: Date, latitude: Double, longitude: Double)] = []
    // Store only the latest location for display
    @Published var currentLocation: (timestamp: Date, latitude: Double, longitude: Double)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let timestamp = location.timestamp
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        //("Received new location: Timestamp: \(timestamp), Lat: \(latitude), Long: \(longitude)")

        
        // Update currentLocation with the latest location for display
        currentLocation = (timestamp: timestamp, latitude: latitude, longitude: longitude)
        
        // Append data to locationData for CSV saving
        locationData.append((timestamp: timestamp, latitude: latitude, longitude: longitude))
        
        // Automatically save to CSV every 10 location updates
        if locationData.count % 10 == 0 {
            saveToCSV { fileURL in
                if let fileURL = fileURL {
                    print("CSV file saved at \(fileURL)")
                } else {
                    print("Failed to save CSV file.")
                }
            }
        }
    }
    
    func saveToCSV(completion: @escaping (URL?) -> Void) {
        var csvText = ""
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("GeoLingo_LocationLog.csv")

        if !fileManager.fileExists(atPath: fileURL.path) {
            csvText += "Timestamp,Latitude,Longitude\n"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.autoupdatingCurrent // Dynamically use the device’s timezone

        for entry in locationData {
            let formattedTimestamp = formatter.string(from: entry.timestamp)
            let newLine = "\(formattedTimestamp),\(entry.latitude),\(entry.longitude)\n"
            csvText.append(contentsOf: newLine)
        }

        do {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = csvText.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            completion(fileURL)
        } catch {
            print("Failed to save CSV file: \(error)")
            completion(nil)
        }
    }
    
    func deleteCSV() {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("GeoLingo_LocationLog.csv")

        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("CSV file deleted successfully.")
            } else {
                print("CSV file does not exist.")
            }
        } catch {
            print("Failed to delete CSV file: \(error)")
        }
    }

}
