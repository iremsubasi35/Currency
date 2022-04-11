//
//  CurrencyTableCell.swift
//  CurrencyConverterApp
//
//  Created by İrem Subaşı on 9.04.2022.
//

import Foundation
import UIKit



protocol CurrencyTableCellDelegate {
    func currencyTableCellEditingChanged(_ cell: CurrencyTableCell, model: CurrencyModel)
}

class CurrencyTableCell: UITableViewCell, UITextFieldDelegate {

    private let viewContent: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.04)
        return view
    }()

    private let lblCountry: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.font = UIFont(name: "AvenirNext-Bold", size: 14)
        return lbl
    }()

    private let lblCurrencyTitle: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.font = UIFont(name: "AvenirNext-Medium", size: 12)
        return lbl
    }()

    private let lblCurrencySymbol: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.font = UIFont(name: "AvenirNext-Regular", size: 12)
        return lbl
    }()

    private let imViewFlag: UIImageView = {
        let imView = UIImageView(frame: .zero)
        imView.translatesAutoresizingMaskIntoConstraints = false
        imView.contentMode = .scaleAspectFit
        imView.clipsToBounds = true
        return imView
    }()

    private let textfieldCurrency: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.font = UIFont(name: "AvenirNext-Medium", size: 14)
        tf.textAlignment = .right
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .decimalPad
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()

    var delegate: CurrencyTableCellDelegate!

    private var currencyModel: CurrencyModel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.addSubview(viewContent)

        viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        viewContent.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true

        viewContent.layer.cornerRadius = 4
        viewContent.layer.masksToBounds = true

        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 16
        viewContent.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.leadingAnchor.constraint(equalTo: self.viewContent.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.viewContent.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: self.viewContent.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.viewContent.bottomAnchor, constant: -8).isActive = true

        let stackViewCountry = UIStackView()
        stackViewCountry.alignment = .fill
        stackViewCountry.distribution = .fill
        stackViewCountry.axis = .vertical

        let imViewFlagWidth: CGFloat = 24
        stackView.addArrangedSubview(imViewFlag)
        imViewFlag.widthAnchor.constraint(equalToConstant: imViewFlagWidth).isActive = true

        stackView.addArrangedSubview(stackViewCountry)

        stackViewCountry.addArrangedSubview(lblCountry)
        stackViewCountry.addArrangedSubview(lblCurrencyTitle)
        stackView.addArrangedSubview(textfieldCurrency)

        lblCurrencySymbol.widthAnchor.constraint(equalToConstant: 28).isActive = true

        textfieldCurrency.delegate = self
        textfieldCurrency.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        currencyModel.currentValue = 0.0
        delegate.currencyTableCellEditingChanged(self, model: currencyModel)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            textField.text = "0.00"
           // textDidChanged()
        }
    }

    @objc private func textDidChanged() {
        guard let valueText = self.textfieldCurrency.text else { return }
        let value: Double = Double((valueText as NSString).doubleValue)
        currencyModel.currentValue = value
        delegate.currencyTableCellEditingChanged(self, model: currencyModel)
//        guard let valueText = self.textfieldCurrency.text else { return }
//        let value: Double = Double((valueText as NSString).doubleValue)
//        let title: String = self.lbl.text ?? ""
//        delegate.currencyTableCellEditingChanged(self, title: title, value: value)
    }

    func configureCell(currencyModel: CurrencyModel) {
        self.currencyModel = currencyModel
        lblCurrencyTitle.text = currencyModel.currencyTitle
        lblCountry.text = currencyModel.country?.name ?? ""
        imViewFlag.image = UIImage(named: currencyModel.flag)
        textfieldCurrency.text = String(format: "%.2f", currencyModel.currentValue)
        lblCurrencySymbol.text = currencyModel.country?.symbol ?? ""

//        lblTitle.text = title
//        textfieldCurrency.text = String(format: "%.2f", value)
    }
}

