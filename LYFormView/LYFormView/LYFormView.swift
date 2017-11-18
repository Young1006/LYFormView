//
//  LYFormView.swift
//  LYFormView
//
//  Created by LiuYang on 2017/11/8.
//  Copyright © 2017年 LiuYang. All rights reserved.
//

import UIKit

private let lineWidth: CGFloat = 1.0
private let textFont: UIFont = UIFont.systemFont(ofSize: 13)
private let extraHeight: CGFloat = 20.0
private let lineColor: CGColor = UIColor(red: 229 / 255.0, green: 229 / 255.0, blue: 229 / 255.0, alpha: 1.0).cgColor
private let textColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)

@objc public protocol FormViewDelegate: NSObjectProtocol {
    
    @objc optional func formView(_ formView: LYFormView, didSelectCellAt indexPath: LYIndexPath)
    
    @objc optional func formView(_ formView: LYFormView, didSelectColumnAt column: Int)
    
    @objc optional func formView(_ formView: LYFormView, didSelectRowAt row: Int)
}

public protocol FormViewDataSource: NSObjectProtocol {
    
    func numberOfRows(in formView: LYFormView) -> Int
    
    func numberOfColumns(in formView: LYFormView) -> Int
    
    func heightForRow(_ formView: LYFormView) -> CGFloat
    
    func widthForColumn(_ formView: LYFormView) -> CGFloat
    
    func formView(_ formView: LYFormView, cellForColumnAt indexPath: LYIndexPath) -> LYFormCell
    
    func subfieldView(forFormView formView: LYFormView) -> LYFormSubfieldView
    
    func columnHeaderView(_ formView: LYFormView, columnHeaderViewAtColumn colmn: Int) -> LYFormColumnHeaderView
    
    func rowHeaderView(_ formView: LYFormView, rowHeaderViewAtColumn row: Int) -> LYFormRowHeaderView
    
}


open class LYFormView: UIScrollView {

    weak open var LYDelegate: FormViewDelegate?
    
    weak open var LYDataSource: FormViewDataSource?
    
    fileprivate lazy var columnHeaderArray = [LYFormColumnHeaderView]()
    fileprivate lazy var rowHeaderArray = [LYFormRowHeaderView]()
    fileprivate lazy var cellArray = [LYFormCell]()
    fileprivate lazy var subfieldArray = [LYFormSubfieldView]()
    
    fileprivate var rows: Int = 0
    fileprivate var columns: Int = 0
    
    fileprivate var columnWidth: CGFloat = 0.0
    fileprivate var rowHeight: CGFloat = 0.0
    
    fileprivate lazy var firstIndexPath = LYIndexPath.indexPathForRow(-1, column: -1)
    fileprivate lazy var maxIndexPath = LYIndexPath.indexPathForRow(-1, column: -1)
    
    fileprivate var subfieldView: LYFormSubfieldView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isDirectionalLockEnabled = true
        self.bounces = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 布局视图
extension LYFormView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        clearUpVisibleCells()
        loadVisibleCells()
    }
    
    private func loadVisibleCells() {
        let originX = self.frame.origin.x
        let originY = self.frame.origin.y
        let formWidth = self.frame.size.width
        let formHeight = self.frame.size.height
        
        if subfieldView?.superview == nil {
            subfieldView?.frame = CGRect(x: originX, y: originY, width: columnWidth, height: rowHeight + extraHeight)
            self.superview?.addSubview(subfieldView!)
        }
        for row in 0..<rows {
            if (CGFloat(row) * rowHeight > self.contentOffset.y + formHeight) || (CGFloat(row + 1) * rowHeight < self.contentOffset.y) {
                continue
            }
            for column in 0..<columns {
                if (CGFloat(column) * columnWidth > self.contentOffset.x + formWidth) || (CGFloat(column + 1) * columnWidth < self.contentOffset.x) {
                    continue
                }
                if column >= firstIndexPath.column && column <= maxIndexPath.column && row >= firstIndexPath.row && row <= maxIndexPath.row {
                    continue
                }
                let rect = CGRect(x: CGFloat(column + 1) * columnWidth, y: CGFloat(row + 1) * rowHeight + extraHeight, width: columnWidth, height: rowHeight)
                if isInRect(rect) {
                    let indexPath = LYIndexPath.indexPathForRow(row, column: column)
                    let cell = LYDataSource?.formView(self, cellForColumnAt: indexPath)
                    cell?.addTarget(self, action: #selector(cellClickAction(_:)), for: .touchUpInside)
                    cell?.indexPath = indexPath
                    cell?.frame = rect
                    insertSubview(cell!, at: 0)
                }
            }
        }
        
        for row in 0..<rows {
            if (CGFloat(row) * rowHeight > self.contentOffset.y + formHeight) || (CGFloat(row + 1) * rowHeight < self.contentOffset.y) {
                continue
            }
            if row >= firstIndexPath.row && row <= maxIndexPath.row {
                continue
            }
            let rect = CGRect(x: self.contentOffset.x + self.contentInset.left, y: CGFloat(row + 1) * rowHeight + extraHeight, width: columnWidth, height: rowHeight)
            if isInRect(rect) {
                let rowHeaderView = LYDataSource?.rowHeaderView(self, rowHeaderViewAtColumn: row)
                rowHeaderView?.addTarget(self, action: #selector(rowClickAction(_:)), for: .touchUpInside)
                rowHeaderView?.frame = rect
                addSubview(rowHeaderView!)
            }
        }
        for column in 0..<columns {
            if (CGFloat(column) * columnWidth > self.contentOffset.x + formWidth) || (CGFloat(column + 1) * columnWidth < self.contentOffset.x) {
                continue
            }
            if column >= firstIndexPath.column && column <= maxIndexPath.column {
                continue
            }
            let rect = CGRect(x: CGFloat(column + 1) * columnWidth, y: self.contentOffset.y + self.contentInset.top, width: columnWidth, height: rowHeight + extraHeight)
            if isInRect(rect) {
                let columnHeaderView = LYDataSource?.columnHeaderView(self, columnHeaderViewAtColumn: column)
                columnHeaderView?.addTarget(self, action: #selector(columnClickAction(_:)), for: .touchUpInside)
                columnHeaderView?.frame = rect
                addSubview(columnHeaderView!)
            }
        }
    }
    
    private func clearUpVisibleCells() {
        
        firstIndexPath = LYIndexPath.indexPathForRow(rows, column: columns)
        maxIndexPath = LYIndexPath.indexPathForRow(0, column: 0)
        
        for subView in self.subviews {
            if !isInRect(subView.frame) {
                if subView.isKind(of: LYFormCell.self) {
                    queueReusableCell(subView as? LYFormCell)
                    subView.removeFromSuperview()
                } else if subView.isKind(of: LYFormRowHeaderView.self) {
                    let headerView = subView as! LYFormRowHeaderView
                    headerView.frame = CGRect(x: self.contentOffset.x + self.contentInset.left, y: headerView.frame.minY, width: headerView.frame.width, height: headerView.frame.height)
                    if !isInRect(headerView.frame) {
                        queueReusableRowHeaderView(headerView)
                        headerView.removeFromSuperview()
                    }
                } else if subView.isKind(of: LYFormColumnHeaderView.self) {
                    let headerView = subView as! LYFormColumnHeaderView
                    headerView.frame = CGRect(x:headerView.frame.minX, y: self.contentOffset.y + self.contentInset.top, width: headerView.frame.width, height: headerView.frame.height)
                    if !isInRect(headerView.frame) {
                        queueReusableColumnHeaderView(headerView)
                        headerView.removeFromSuperview()
                    }
                }
            } else {
                if subView.isKind(of: LYFormColumnHeaderView.self) {
                    subView.frame = CGRect(x: subView.frame.minX, y: self.contentOffset.y + self.contentInset.top, width: subView.frame.width, height: subView.frame.height)
                } else if subView.isKind(of: LYFormRowHeaderView.self) {
                    subView.frame = CGRect(x: self.contentOffset.x + self.contentInset.left, y: subView.frame.minY, width: subView.frame.width, height: subView.frame.height)
                } else if subView.isKind(of: LYFormCell.self) {
                    if let cell = subView as? LYFormCell {
                        if (cell.indexPath?.row)! <= firstIndexPath.row && (cell.indexPath?.column)! <= firstIndexPath.column {
                            firstIndexPath = LYIndexPath.indexPathForRow((cell.indexPath?.row)!, column: (cell.indexPath?.column)!)
                        }
                        if (cell.indexPath?.row)! >= maxIndexPath.row && cell.indexPath!.column >= maxIndexPath.column {
                            maxIndexPath = LYIndexPath.indexPathForRow((cell.indexPath?.row)!, column: (cell.indexPath?.column)!)
                        }
                    }
                }
            }
        }
    }
    
    private func isInRect(_ rect: CGRect) -> Bool {
        return rect.intersects(CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.frame.size.width, height: self.frame.size.height))
    }
}

// MARK: - 视图复用
extension LYFormView {
    public func dequeueReusableColumnHeaderView(withIdentifier identifier: String) -> LYFormColumnHeaderView? {
        var temp: LYFormColumnHeaderView?
        columnHeaderArray = columnHeaderArray.filter({ (headerView) -> Bool in
            if headerView.identifier == identifier {
                temp = headerView
                return false
            }
            return true
        })
        return temp
    }
    
    public func dequeueReusableRowHeaderView(withIdentifier identifier: String) -> LYFormRowHeaderView? {
        var temp: LYFormRowHeaderView?
        rowHeaderArray = rowHeaderArray.filter({ (headerView) -> Bool in
            if headerView.identifier == identifier {
                temp = headerView
                return false
            }
            return true
        })
        return temp
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String) -> LYFormCell? {
        var temp: LYFormCell?
        cellArray = cellArray.filter({ (headerView) -> Bool in
            if headerView.identifier == identifier {
                temp = headerView
                return false
            }
            return true
        })
        return temp
    }
    
    public func dequeueReusableSubfieldView() -> LYFormSubfieldView? {
        var temp: LYFormSubfieldView?
        subfieldArray = subfieldArray.filter({ (headerView) -> Bool in
            temp = headerView
            return true
        })
        return temp
    }
    
    private func queueReusableCell(_ cell: LYFormCell?) {
        if cell != nil {
            cell!.indexPath = nil
            cell! .removeTarget(self, action: #selector(cellClickAction(_:)), for: .touchUpInside)
            cellArray.append(cell!)
        }
    }
    
    private func queueReusableColumnHeaderView(_ columnHeaderView: LYFormColumnHeaderView?) {
        if columnHeaderView != nil {
            columnHeaderView!.column = -1
            columnHeaderView!.removeTarget(self, action: #selector(columnClickAction(_:)), for: .touchUpInside)
            columnHeaderArray.append(columnHeaderView!)
        }
    }
    
    private func queueReusableRowHeaderView(_ rowHeaderView: LYFormRowHeaderView?) {
        if rowHeaderView != nil {
            rowHeaderView!.row = -1
            rowHeaderView!.removeTarget(self, action: #selector(rowClickAction(_:)), for: .touchUpInside)
            rowHeaderArray.append(rowHeaderView!)
        }
    }
    
    private func queueReusableSubfieldView(_ subfieldView: LYFormSubfieldView?) {
        if subfieldView != nil {
            subfieldArray.append(subfieldView!)
        }
    }
    
}

// MARK: - 刷新表格
extension LYFormView {
    public func reLoad() {
        if LYDataSource == nil {
            return
        }
        for subView in self.subviews {
            if subView.isKind(of: LYFormColumnHeaderView.self) {
                queueReusableColumnHeaderView(subView as? LYFormColumnHeaderView)
            } else if subView.isKind(of: LYFormRowHeaderView.self) {
                queueReusableRowHeaderView(subView as? LYFormRowHeaderView)
            } else if subView.isKind(of: LYFormCell.self) {
                queueReusableCell(subView as? LYFormCell)
            } else if subView.isKind(of: LYFormSubfieldView.self) {
                queueReusableSubfieldView(subView as? LYFormSubfieldView)
            }
            subView.removeFromSuperview()
        }
        
        guard let rowsCount = LYDataSource?.numberOfRows(in: self) else {
            return
        }
        rows = rowsCount
        
        guard let columnsCount = LYDataSource?.numberOfColumns(in: self) else {
            return
        }
        columns = columnsCount
        
        guard let width = LYDataSource?.widthForColumn(self) else {
            return
        }
        columnWidth = width
        
        guard let height = LYDataSource?.heightForRow(self) else {
            return
        }
        rowHeight = height
        
        subfieldView = LYDataSource?.subfieldView(forFormView: self)
        
        self.contentSize = CGSize(width: CGFloat(columns + 1) * columnWidth, height: CGFloat(rows + 1) * rowHeight + extraHeight)
        
        setNeedsLayout()
    }
}

// MARK: - 点击事件 -
extension LYFormView {
    
    @objc fileprivate func cellClickAction(_ cell: LYFormCell) {
        if LYDelegate != nil {
            LYDelegate?.formView!(self, didSelectCellAt: cell.indexPath!)
        }
    }
    
    @objc fileprivate func columnClickAction(_ columnHeaderView: LYFormColumnHeaderView) {
        if LYDelegate != nil {
            LYDelegate?.formView!(self, didSelectColumnAt: columnHeaderView.column)
        }
    }
    
    @objc fileprivate func rowClickAction(_ rowHeaderView: LYFormRowHeaderView) {
        if LYDelegate != nil {
            LYDelegate?.formView!(self, didSelectRowAt: rowHeaderView.row)
        }
    }
}

open class LYFormCell: UIButton {
    
    fileprivate var identifier: String?
    fileprivate var indexPath: LYIndexPath?
    
    init(frame:CGRect, identifier: String?) {
        super.init(frame: frame)
        self.identifier = identifier
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor)
            var points = [CGPoint]()
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: rect.width, y: 0))
            points.append(CGPoint(x: rect.width, y: rect.height))
            points.append(CGPoint(x: 0, y: rect.height))
            points.append(CGPoint(x: 0, y: 0))
            context.addLines(between: points)
            context.drawPath(using: .stroke)
        }
    }
}

open class LYFormRowHeaderView: UIButton {
    
    fileprivate var identifier: String?
    fileprivate var row: Int = 0
    
    init(frame:CGRect, identifier: String?) {
        super.init(frame: frame)
        self.identifier = identifier
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor)
            var points = [CGPoint]()
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: rect.width, y: 0))
            points.append(CGPoint(x: rect.width, y: rect.height))
            points.append(CGPoint(x: 0, y: rect.height))
            points.append(CGPoint(x: 0, y: 0))
            context.addLines(between: points)
            context.drawPath(using: .stroke)
        }
    }
}


open class LYFormColumnHeaderView: UIButton {
    
    fileprivate var identifier: String?
    fileprivate var column: Int = 0
    
    init(frame:CGRect, identifier: String?) {
        super.init(frame: frame)
        self.identifier = identifier
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor)
            var points = [CGPoint]()
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: rect.width, y: 0))
            points.append(CGPoint(x: rect.width, y: rect.height))
            points.append(CGPoint(x: 0, y: rect.height))
            points.append(CGPoint(x: 0, y: 0))
            context.addLines(between: points)
            context.drawPath(using: .stroke)
        }
    }
}


open class LYFormSubfieldView: UIView {
    
    fileprivate var rowTitle: String?
    fileprivate var columnTitle: String?
    
    init(frame:CGRect, rowTitle: String?, columnTitle: String?) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.rowTitle = rowTitle
        self.columnTitle = columnTitle
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attributes = [NSAttributedStringKey.foregroundColor:textColor,NSAttributedStringKey.font:textFont,NSAttributedStringKey.paragraphStyle:style];
            if let columnT = columnTitle {
                if columnT.count > 0 {
                    (columnT as NSString).draw(in: CGRect(x: rect.width * 0.5, y:5, width: rect.width * 0.5, height: rect.height * 0.5), withAttributes: attributes)
                    context.strokePath()
                }
            }
            if let rowT = rowTitle {
                if rowT.count > 0 {
                    (rowT as NSString).draw(in: CGRect(x: 0, y: rect.height * 0.5, width: rect.width * 0.5, height: rect.height * 0.5), withAttributes: attributes)
                    context.strokePath()
                }
            }
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor)
            var points = [CGPoint]()
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: rect.width, y: 0))
            points.append(CGPoint(x: rect.width, y: rect.height))
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: 0, y: rect.height))
            points.append(CGPoint(x: rect.width, y: rect.height))
            context.addLines(between: points)
            context.drawPath(using: .stroke)
        }
    }
}


open class LYIndexPath: NSObject {
    var row: Int = -1
    var column: Int = -1
    fileprivate class func indexPathForRow(_ row: Int, column: Int) -> LYIndexPath {
        let indexPath = LYIndexPath()
        indexPath.row = row
        indexPath.column = column
        return indexPath
    }
}
