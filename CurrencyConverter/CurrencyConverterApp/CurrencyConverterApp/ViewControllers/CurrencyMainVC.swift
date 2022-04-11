//
//  CurrencyMainVC.swift
//  CurrencyConverterApp
//
//  Created by İrem Subaşı on 8.04.2022.
//

import Foundation
import UIKit
import Alamofire


class CurrencyMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CurrencyTableCellDelegate, UISearchResultsUpdating {

    private var currencyModels: [CurrencyModel] = []
    private var filteredCurrencyModels: [CurrencyModel] = []
    private var keywordSearch: String?
//    private var rates: [String: Double] = [:]
//    private var currentRates: [String: Double] = [:]
//    private var sortedKeys: [String] = []
//    private var countries: [String: String] = [:]

    private let tableViewCurrency: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        return table
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(frame: .zero)
        act.translatesAutoresizingMaskIntoConstraints = false
        act.style = .large
        return act
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })

        configureUI()
        fetchRatesInfo()
    }

    private func configureUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        //appearance.titleTextAttributes = [.font : UIFont(name: "AvenirNext-Bold", size: 39)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        self.title = "Currencies"
        self.view.backgroundColor = UIColor(red: 30 / 255, green: 33 / 255, blue: 52 / 255, alpha: 1.0)
        self.tableViewCurrency.backgroundColor = .clear
        self.view.addSubview(tableViewCurrency)

        tableViewCurrency.keyboardDismissMode = .onDrag

        tableViewCurrency.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableViewCurrency.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        tableViewCurrency.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        tableViewCurrency.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        tableViewCurrency.register(CurrencyTableCell.self, forCellReuseIdentifier: "CurrencyTableCell")
        tableViewCurrency.delegate = self
        tableViewCurrency.dataSource = self

        self.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        activityIndicator.isHidden = true
        tableViewCurrency.isHidden = false

        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Ara"
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }

    func updateSearchResults(for searchController: UISearchController) {
        self.keywordSearch = searchController.searchBar.text
        self.applyFilter()
        self.tableViewCurrency.reloadData()
    }

    private func fetchRatesInfo() {
        activityIndicator.isHidden = false
        tableViewCurrency.isHidden = true

        if let responseData = readResponseFromFile() {
            self.handleResponseData(responseData)
            self.activityIndicator.isHidden = true
            self.tableViewCurrency.isHidden = false
        } else {
            let url = "http://api.exchangeratesapi.io/v1/latest?access_key=6d93e12944111b9762b3de32fbe7202b"
            AF.request(url).responseData { data in
                self.handleResponseData(data.value)
                self.saveResponseData(data.value)
                self.activityIndicator.isHidden = true
                self.tableViewCurrency.isHidden = false
            }
        }
    }

    private func readResponseFromFile() -> Data? {
        let timeSaved = UserDefaults.standard.double(forKey: "CRSavedTime")
        let diff = Date().timeIntervalSince1970 - timeSaved
        guard diff < (60 * 60 * 6) else { return nil }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory.appendingPathComponent("CurrencyResponse").appendingPathExtension("json")
        guard FileManager.default.fileExists(atPath: filePath.path) else { return nil }
        return try? Data(contentsOf: filePath)
    }

    private func saveResponseData(_ data: Data?) {
        guard let data = data else {
            return
        }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory.appendingPathComponent("CurrencyResponse").appendingPathExtension("json")
        do {
            try data.write(to: filePath)
            let currentTime = Date().timeIntervalSince1970
            UserDefaults.standard.set(currentTime, forKey: "CRSavedTime")
            UserDefaults.standard.synchronize()
        } catch {

        }
    }

    private func handleResponseData(_ data: Data?) {
        guard
            let data = data,
            let currencyResponse = try? JSONDecoder().decode(CurrencyResponse.self, from: data),
            let countriesURL = Bundle.main.url(forResource: "countries", withExtension: "json"),
            let countriesData = try? Data(contentsOf: countriesURL),
            let countriesResponse = try? JSONDecoder().decode(CountryResponse.self, from: countriesData)
        else {
            return
        }

        var countriesDictionary: [String: Country] = [:]
        countriesResponse.countries.forEach {
            countriesDictionary[$0.cc] = $0
        }

        let currencyRates = currencyResponse.rates
        currencyModels = []

        currencyRates.keys.forEach { rateKey in
            let country = countriesDictionary[rateKey.uppercased()]
            let flag = rateKey.lowercased()
            let rate = currencyRates[rateKey] ?? 0.0
            let model = CurrencyModel(flag: flag, rate: rate, country: country, currencyTitle: rateKey.uppercased())
            model.currentValue = rate
            currencyModels.append(model)
            filteredCurrencyModels.append(model)
        }

        currencyModels.sort { model1, model2 in
            model1.currencyTitle < model2.currencyTitle
        }
        applyFilter()

        tableViewCurrency.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCurrencyModels.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentModel = filteredCurrencyModels[indexPath.row]
        let cell: CurrencyTableCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableCell", for: indexPath) as! CurrencyTableCell
        cell.configureCell(currencyModel: currentModel)
        cell.delegate = self
        return cell
    }

    func currencyTableCellEditingChanged(_ cell: CurrencyTableCell, model: CurrencyModel) {
        let euroValue = model.currentValue / model.rate
        for index in 0 ..< currencyModels.count {
            currencyModels[index].currentValue = euroValue * currencyModels[index].rate
        }
        applyFilter()

        var indexPathsToUpdate: [IndexPath] = []
        for index in 0 ..< filteredCurrencyModels.count {
            let currModel = filteredCurrencyModels[index]
            if currModel.currencyTitle != model.currencyTitle {
                indexPathsToUpdate.append(.init(row: index, section: 0))
            } else {
                NSLog("Found At: \(index)")
            }
        }

    self.tableViewCurrency.reloadRows(at: indexPathsToUpdate, with: .none)
    }

    private func applyFilter() {
        guard let keywordSearch = keywordSearch, keywordSearch.isEmpty == false else {
            filteredCurrencyModels = currencyModels
            return
        }

        filteredCurrencyModels = currencyModels.filter {
            var countrySuccess = false
            var currencySuccess = false

            if let country = $0.country {
                countrySuccess = country.name.lowercased().contains(keywordSearch.lowercased())
                currencySuccess = $0.currencyTitle.lowercased().contains(keywordSearch.lowercased())
                return countrySuccess || currencySuccess
            } else {
                currencySuccess = $0.currencyTitle.lowercased().contains(keywordSearch.lowercased())
                return currencySuccess
            }

        }
    }

}
