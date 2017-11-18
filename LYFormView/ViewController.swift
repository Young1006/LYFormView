//
//  ViewController.swift
//  LYFormView
//
//  Created by LiuYang on 2017/11/8.
//  Copyright © 2017年 LiuYang. All rights reserved.
//

import UIKit

private let cellTextColor: UIColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
private let headerTextColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)

private typealias DatasType = [[String:Any]]

private let topMargin: CGFloat = 20.0

private let cellIdentifier   = "cellIdentifier"
private let rowIdentifier    = "rowIdentifier"
private let columnIdentifier = "columnIdentifier"

class ViewController: UIViewController {
    
    fileprivate var datasArr: DatasType?
    
    fileprivate var formView: LYFormView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasArrayFromPlist()
        formView = LYFormView(frame: CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin))
        formView?.LYDelegate = self
        formView?.LYDataSource = self
        view.addSubview(formView!)
        
        formView?.reLoad()
    }

    private func datasArrayFromPlist() {
        if let path = Bundle.main.path(forResource: "datas", ofType: "plist") {
            if let tempArr = NSArray(contentsOfFile: path) as? DatasType {
                datasArr = tempArr
            }
        }
    }
}


extension ViewController: FormViewDelegate, FormViewDataSource {
    
    func numberOfRows(in formView: LYFormView) -> Int {
        return datasArr != nil ? datasArr!.count : 0
    }
    
    func numberOfColumns(in formView: LYFormView) -> Int {
        return 10
    }
    
    func heightForRow(_ formView: LYFormView) -> CGFloat {
        return 30
    }
    
    func widthForColumn(_ formView: LYFormView) -> CGFloat {
        return 60
    }
    
    func formView(_ formView: LYFormView, cellForColumnAt indexPath: LYIndexPath) -> LYFormCell {
        var cell = formView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = LYFormCell(frame: CGRect.zero, identifier: cellIdentifier)
        }
        let dict = datasArr![indexPath.row]
        cell?.setTitle(dict["name"] as? String, for: .normal)
        cell?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        cell?.setTitleColor(cellTextColor, for: .normal)
        return cell!
    }
    
    func rowHeaderView(_ formView: LYFormView, rowHeaderViewAtColumn row: Int) -> LYFormRowHeaderView {
        var rowHeaderView = formView.dequeueReusableRowHeaderView(withIdentifier: rowIdentifier)
        if rowHeaderView == nil {
            rowHeaderView = LYFormRowHeaderView(frame: CGRect.zero, identifier: rowIdentifier)
        }
        rowHeaderView?.setTitle("第\(row)行", for: .normal)
        rowHeaderView?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        rowHeaderView?.setTitleColor(headerTextColor, for: .normal)
        return rowHeaderView!
    }
    
    func columnHeaderView(_ formView: LYFormView, columnHeaderViewAtColumn colmn: Int) -> LYFormColumnHeaderView {
        var columnHeaderView = formView.dequeueReusableColumnHeaderView(withIdentifier: columnIdentifier)
        if columnHeaderView == nil {
            columnHeaderView = LYFormColumnHeaderView(frame: CGRect.zero, identifier: columnIdentifier)
        }
        columnHeaderView?.setTitle("第\(colmn)行", for: .normal)
        columnHeaderView?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        columnHeaderView?.setTitleColor(headerTextColor, for: .normal)
        return columnHeaderView!
    }
    
    func subfieldView(forFormView formView: LYFormView) -> LYFormSubfieldView {
        var subfield = formView.dequeueReusableSubfieldView()
        if subfield == nil {
            subfield = LYFormSubfieldView(frame: CGRect.zero, rowTitle: "行数", columnTitle: "列数")
        }
        return subfield!
    }
    
    func formView(_ formView: LYFormView, didSelectRowAt row: Int) {
        print("row ====== \(row)")
    }
    
    func formView(_ formView: LYFormView, didSelectColumnAt column: Int) {
        print("column ====== \(column)")
    }
    
    func formView(_ formView: LYFormView, didSelectCellAt indexPath: LYIndexPath) {
        print("row ====== \(indexPath.row), column ====== \(indexPath.column)")
    }
}


