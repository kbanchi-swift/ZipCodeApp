//
//  ViewController.swift
//  ZipCodeApp
//
//  Created by 伴地慶介 on 2021/11/06.
//

import UIKit

struct ZipCloudResponse: Codable {
    let message: String?
    let results: [OneAddressInfo]?
    let status: Int
}

struct OneAddressInfo: Codable {
    let address1: String
    let address2: String
    let address3: String
    let kana1: String
    let kana2: String
    let kana3: String
    let prefcode: String
    let zipcode: String
    
    func address() -> String {
         return address1 + address2 + address3
    }
    
    func kana() -> String {
         return kana1 + kana2 + kana3
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var zipCodeSearchBar: UISearchBar!
    
    @IBOutlet weak var addressTableView: UITableView!
    
    var results: [OneAddressInfo] = []
    let baseUrlStr = "https://zipcloud.ibsnet.co.jp/api/search?zipcode="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        zipCodeSearchBar.delegate = self
        addressTableView.dataSource = self
    }
    
    func requestAddressFromZipCode(zipCode: String) {
        
        var responseData: ZipCloudResponse?
        let urlStr = baseUrlStr + zipCode
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                responseData = try decoder.decode(ZipCloudResponse.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
            
//            if responseData?.results != nil {
//                self.results = (responseData?.results)!
//            }
            
            DispatchQueue.main.async {
                if responseData?.results != nil {
                    self.results = (responseData?.results)!
                } else {
                    self.showAlert(title: "ERROR", message: "There is no zipCode")
                }
                self.addressTableView.reloadData()
            }
        }
        task.resume()
    }
    
    func isZipCode(enteredText: String) -> Bool {
        let pattern = "^[0-9]{7}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: enteredText, range: NSRange(location: 0, length: enteredText.count))
        return matches.count == 1 ? true : false
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        guard isZipCode(enteredText: searchText) else {
            print("Please input 7 of numbers")
            showAlert(title: "ERROR", message: "Please Input 7 of numbers")
            return
        }
        requestAddressFromZipCode(zipCode: searchText)
    }
    
}

extension ViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        let address = results[indexPath.row]
//        cell.textLabel?.text = address.address1
//            + address.address2
//            + address.address3
//            + "("
//            + address.kana1
//            + address.kana2
//            + address.kana3
//            + ")"
        cell.textLabel?.text = "\(address.address())(\(address.kana()))"
        return cell
    }

}
