//
//  ViewController.swift
//  Currency App
//
//  Created by Liuning Weng on 10/21/21.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var baseValueText: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var toText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    let pickerView = UIPickerView()
    var currencyCode: [String] = []
    var currencyRate: [String:Double] = [:]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        fetchJSON()
        fromText.inputView = pickerView
        toText.inputView = pickerView
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        let fromRate = currencyRate[fromText.text ?? ""] ?? 1
        let toRate = currencyRate[toText.text ?? ""] ?? 0
        let baseValue = Double(baseValueText.text ?? "") ?? 0
        let price = toRate / fromRate * baseValue
        let formattedPrice = String(format: "%.2f", price)
        self.priceLabel.text = formattedPrice
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyCode.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyCode[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currencyName = currencyCode[row]
        if fromText.isFirstResponder {
            fromText.text = currencyName
        } else if toText.isFirstResponder {
            toText.text = currencyName
        }
    }
    
    //Method
    func fetchJSON() {
        guard let url = URL(string: "http://api.exchangeratesapi.io/v1/latest?access_key=e73ab1c563f49ddbd804eb0d74458cca") else { return }
        URLSession.shared.dataTask(with: url){(data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let safeData = data else {return}
            do {
                let results = try JSONDecoder().decode(ExchangeRates.self, from: safeData)
                self.currencyCode.append(contentsOf: results.rates.keys.sorted())
                self.currencyRate = results.rates
                DispatchQueue.main.async {
                    self.pickerView.reloadAllComponents()
                }
               
            } catch {
                print(error)
            }
        }.resume()
    }

}

