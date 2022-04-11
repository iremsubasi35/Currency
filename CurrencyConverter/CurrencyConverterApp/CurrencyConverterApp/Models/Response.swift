//
//  CurrencyResponse.swift
//  CurrencyConverterApp
//
//  Created by İrem Subaşı on 9.04.2022.
//

import Foundation

class CurrencyModel {
    let flag: String
    let rate: Double
    let currencyTitle: String
    let country: Country?
    var currentValue: Double

    init(flag: String, rate: Double, country: Country?, currencyTitle: String) {
        self.flag = flag
        self.rate = rate
        self.currencyTitle = currencyTitle
        self.country = country
        self.currentValue = 0
    }
}


struct CurrencyResponse: Decodable {
    let base: String
    let success: Bool
    let rates: [String: Double]
}

struct Country: Decodable {
    let cc: String
    let symbol: String
    let name: String
}

struct CountryResponse: Decodable {
    let countries: [Country]
}


