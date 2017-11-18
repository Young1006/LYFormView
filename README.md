# LYFormView
滑动流畅的表格视图（类似于Excel），仿照UITableViewCell复用机制，简洁高效。

# 功能简介
采用Reusable机制
添加横表头（RowHeaderView）
添加竖表头（ColumnHeaderView）
添加左上角分类表头（SubFieldView）
通过FormViewDataSource去创建各个元素，类似TableView
表头及表格添加点击事件

# 使用示例
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

