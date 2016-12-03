//
//  TableViewController.swift
//  Currency
//
//  Created by Nuno Coelho Santos on 28/02/2016.
//  Copyright © 2016 Nuno Coelho Santos. All rights reserved.
//

import UIKit
import CoreData

protocol ChangeCurrencyViewControllerDelegate {
    func didChangeCurrency(_ currencyCode: String, targetCurrency: String)
}

class ChangeCurrencyViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    var delegate: ChangeCurrencyViewControllerDelegate?
    var targetCurrency: String!
    var selectedCurrency: String!
    var currencies:Array<Currency>!
    var recentCurrencies:Array<Currency>!
    var searchResults:Array<Currency>?
    var tableData:Array<Array<Currency>>!
    var tableSectionTitles:Array<String>!
    let displayChineseSimplified: Bool = "zh-Hans-US" == Locale.preferredLanguages[0]
    let displayChineseTraditional: Bool = ["zh-Hant-US", "zh-HK", "zh-TW"].contains(Locale.preferredLanguages[0])
    let displayJapanese: Bool = String(Locale.preferredLanguages[0].characters.prefix(2)) == "ja"
    let displayPortuguese: Bool = String(Locale.preferredLanguages[0].characters.prefix(2)) == "pt"
    let displaySpanish: Bool = String(Locale.preferredLanguages[0].characters.prefix(2)) == "es"

    @IBOutlet weak var tableView: UITableView!

    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 54.0
        self.searchDisplayController?.searchResultsTableView.rowHeight = 54.0
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext as NSManagedObjectContext

        currencies = fetchCurrencies()
        recentCurrencies = fetchRecentCurrencies()
        tableData = [recentCurrencies, currencies]
        if displayChineseSimplified {
            tableSectionTitles = ["近期货币", "所有货币"]
        } else if displayChineseTraditional {
            tableSectionTitles = ["近期貨幣", "所有貨幣"]
        } else if displayJapanese {
            tableSectionTitles = ["最近の通貨", "すべての通貨"]
        } else if displayPortuguese {
            tableSectionTitles = ["Moedas recentes", "Todas as moedas"]
        } else if displaySpanish {
            tableSectionTitles = ["Monedas recientes", "Todas las monedas"]
        } else {
            tableSectionTitles = ["Recent currencies", "All currencies"]
        }
    }

    func fetchCurrencies() -> [Currency]{
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency")
        var sortDescriptor: NSSortDescriptor
        
        if displayChineseSimplified {
            sortDescriptor = NSSortDescriptor(key: "name_zh_Hans", ascending: true)
        } else if displayChineseTraditional {
            sortDescriptor = NSSortDescriptor(key: "name_zh_Hant", ascending: true)
        } else if displayJapanese {
            sortDescriptor = NSSortDescriptor(key: "name_ja", ascending: true)
        } else if displayPortuguese {
            sortDescriptor = NSSortDescriptor(key: "name_pt_PT", ascending: true)
        } else if displaySpanish {
            sortDescriptor = NSSortDescriptor(key: "name_es", ascending: true)
        } else {
            sortDescriptor = NSSortDescriptor(key: "name_en", ascending: true)
        }
        
        let sortDescriptors = [sortDescriptor]
        fetch.sortDescriptors = sortDescriptors
        var result = [AnyObject]()
        do {
            result = try managedObjectContext!.fetch(fetch)
        } catch let error as NSError {
            print("Error fetching currencies error: %@", error)
        }
        return result as! [Currency]
    }

    func fetchRecentCurrencies() -> [Currency]{
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency")
        let sortDescriptor = NSSortDescriptor(key: "lastSelected", ascending: false)
        let sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "lastSelected != nil")
        fetch.sortDescriptors = sortDescriptors
        fetch.predicate = predicate
        fetch.fetchLimit = 5
        var result = [AnyObject]()
        do {
            result = try managedObjectContext!.fetch(fetch)
        } catch let error as NSError {
            print("Error fetching recent currencies error: %@", error)
        }
        return result as! [Currency]
    }

}

// MARK: - Table View

extension ChangeCurrencyViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return 1
        } else {
            return tableData.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return searchResults?.count ?? 0
        } else {
            return tableData[section].count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CurrencyCell")
        let currency: Currency
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            currency = searchResults![indexPath.row]
        } else {
            currency = tableData[indexPath.section][indexPath.row]
        }
        if displayChineseSimplified {
            cell!.textLabel!.text = currency.name_zh_Hans!
        } else if displayChineseTraditional {
            cell!.textLabel!.text = currency.name_zh_Hant!
        } else if displayJapanese {
            cell!.textLabel!.text = currency.name_ja!
        } else if displayPortuguese {
            cell!.textLabel!.text = currency.name_pt_PT!
        } else if displaySpanish {
            cell!.textLabel!.text = currency.name_es!
        } else {
            cell!.textLabel!.text = currency.name_en!
        }
        cell!.detailTextLabel!.text = currency.code!
        cell!.accessoryType = UITableViewCellAccessoryType.none

        if currency.code! == selectedCurrency {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return nil
        } else {
            return tableSectionTitles[section]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableData[section].count == 0) {
            return 0.0
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency: Currency
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            currency = searchResults![indexPath.row]
        } else {
            currency = tableData[indexPath.section][indexPath.row]
        }
        
        let currencyCode = currency.code!

        delegate?.didChangeCurrency(currencyCode, targetCurrency: targetCurrency)
        self.dismiss(animated: true, completion: {})
    }

}

// MARK: - Search

extension ChangeCurrencyViewController: UISearchBarDelegate, UISearchDisplayDelegate {

    func filterContentForSearchText(_ searchText: String) {

        var filteredContent:Array<Currency> = []
        let searchText = searchText.lowercased()

        for currency in currencies {
            var matchesName: Bool = false
            if displayChineseSimplified {
                matchesName = currency.name_zh_Hans!.lowercased().range(of: searchText) != nil
            } else if displayChineseTraditional {
                matchesName = currency.name_zh_Hant!.lowercased().range(of: searchText) != nil
            } else if displayJapanese {
                matchesName = currency.name_ja!.lowercased().range(of: searchText) != nil
            } else if displayPortuguese {
                matchesName = currency.name_pt_PT!.lowercased().range(of: searchText) != nil
            } else if displaySpanish {
                matchesName = currency.name_es!.lowercased().range(of: searchText) != nil
            } else {
                matchesName = currency.name_en!.lowercased().range(of: searchText) != nil
            }
        
            let matchesCode = currency.code!.lowercased().range(of: searchText) != nil

            if (matchesName || matchesCode) {
                filteredContent += [currency]
            }
        }

        self.searchResults = filteredContent
    }

    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }

}
