//
//  ViewController.swift
//  GeoLingo
//
//  Created by Naomi K on 2024-11-12.
//

import UIKit
import CoreLocation
import Combine

class ViewController: UIViewController, UITableViewDataSource {
    var locationManager = LocationManager()
    private var cancellable: AnyCancellable?
    private let locationLabel = UILabel()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationLabel()
        setupTableView()
        setupShareButton()
        setupDeleteButton()
        observeCurrentLocation()
    }
    
    func setupLocationLabel() {
        locationLabel.textColor = .black
        locationLabel.textAlignment = .center
        locationLabel.numberOfLines = 0
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupTableView() {
        // Register the cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Set up constraints for the table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }
    
    func setupShareButton() {
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Share CSV", for: .normal)
        shareButton.addTarget(self, action: #selector(shareCSVFile), for: .touchUpInside)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func setupDeleteButton() {
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete CSV", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteCSVFile), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }

    @objc func deleteCSVFile() {
        locationManager.deleteCSV()
    }


    private func observeCurrentLocation() {
        cancellable = locationManager.$currentLocation
            .sink { [weak self] currentLocation in
                guard let currentLocation = currentLocation else { return }
                self?.updateLocationLabel(with: currentLocation)
            }
    }

    private func updateLocationLabel(with location: (timestamp: Date, latitude: Double, longitude: Double)) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.autoupdatingCurrent // Dynamically use the device’s timezone
        
        // Convert timestamp to a string in the local timezone
        let timestampString = formatter.string(from: location.timestamp)
        
        // Debugging output
            //print("Updating label with: Timestamp: \(timestampString), Lat: \(location.latitude), Long: \(location.longitude)")
        
        // Display the current location's timestamp and coordinate
        DispatchQueue.main.async { [weak self] in
                self?.locationLabel.text = """
                Timestamp: \(timestampString)
                Lat: \(location.latitude), Long: \(location.longitude)
                """
            }
    }

    @objc func shareCSVFile() {
        locationManager.saveToCSV { [weak self] fileURL in
            guard let fileURL = fileURL else {
                print("No file URL available to share")
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self?.present(activityVC, animated: true, completion: nil)
        }
    }
    

    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show only the current location (1 row if it exists, 0 if it doesn't)
        return locationManager.currentLocation == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Display only the current (latest) location
        if let entry = locationManager.currentLocation {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = .current // Ensure it’s using the device’s local timezone
            let timestampString = formatter.string(from: entry.timestamp)
            
            cell.textLabel?.text = "Timestamp: \(timestampString)"
            cell.detailTextLabel?.text = "Lat: \(entry.latitude), Long: \(entry.longitude)"
        }
        
        return cell
    }

}



/*
import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource {
    var locationManager = LocationManager()
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupShareButton()
    }

    func setupTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func setupShareButton() {
        // Add a Share button to the view
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Share CSV", for: .normal)
        shareButton.addTarget(self, action: #selector(shareCSVFile), for: .touchUpInside)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        // Set up constraints for the button
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc func shareCSVFile() {
        // Call saveToCSV and present the share sheet when the file is ready
        locationManager.saveToCSV { [weak self] fileURL in
            guard let fileURL = fileURL else {
                print("No file URL available to share")
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self?.present(activityVC, animated: true, completion: nil)
        }
    }

    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationManager.locationData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let entry = locationManager.locationData[indexPath.row]
        cell.textLabel?.text = "Timestamp: \(entry.timestamp)"
        cell.detailTextLabel?.text = "Lat: \(entry.latitude), Long: \(entry.longitude)"
        return cell
    }
}
*/

