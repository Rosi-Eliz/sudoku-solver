
import UIKit

class SudokuView: UIView {
    
    private enum Constants {
        static let offset: CGFloat = 2
        static let rows = 9
        static let columns = 9
        static let separationMod = 3
        static let minorOutline: CGFloat = 1
        static let majorOutline: CGFloat = 2
        static let strokeColor = UIColor.darkGray
        static let initialValueColor = UIColor.darkGray
        static let solvedValueColor = UIColor(red: 0/255, green: 204/255, blue: 0/255, alpha: 1.0)
    }
    
    private var dataSource: DataSource?
    
    struct DataSource {
        let initialPairs: [ValueData]
        let solvedPairs: [ValueData]
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setDataSource(_ dataSource: DataSource) {
        self.dataSource = dataSource
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawInitialValuePairs()
        drawSolvedValuePairs()
        drawOutlines()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - Drawing

private extension SudokuView {
    
    var width: CGFloat {
        return bounds.width - Constants.offset
    }
    
    var height: CGFloat {
        return bounds.height - Constants.offset
    }
    
    var size: CGFloat {
        return min(width, height)
    }
    
    var interColumnsSpacing: CGFloat {
        return size / CGFloat(Constants.columns)
    }
    
    var interRowsSpacing: CGFloat {
        return size / CGFloat(Constants.rows)
    }
    
    var boundsCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
    
    var originX: CGFloat {
        return boundsCenter.x - size / 2 + Constants.offset / 2
    }
    
    var originY: CGFloat {
        return boundsCenter.y - size / 2 + Constants.offset / 2
    }
    
    func drawOutlines() {
        
        let firstColumnIndex = 0
        let lastColumnIndex = Constants.columns - 1
        
        let firstRowIndex = 0
        let lastRowIndex = Constants.columns - 1
        
        let context = UIGraphicsGetCurrentContext()
        for i in firstColumnIndex...lastColumnIndex + 1 {
            let columnLineShouldBeBolded = i == firstColumnIndex || (i) % Constants.separationMod == 0
            let strokeWidth = columnLineShouldBeBolded ? Constants.majorOutline : Constants.minorOutline
            context?.setLineWidth(strokeWidth)
            
            context?.move(to: CGPoint(x: originX + CGFloat(i) * interRowsSpacing,
                                      y: originY))
            
            context?.addLine(to: CGPoint(x: originX + CGFloat(i) * interRowsSpacing,
                                         y: originY + size))
            context?.setStrokeColor(Constants.strokeColor.cgColor)
            context?.strokePath()
        }
        
        for i in firstRowIndex...lastRowIndex + 1 {
            let columnLineShouldBeBolded = i == firstRowIndex || (i) % Constants.separationMod == 0
            let strokeWidth = columnLineShouldBeBolded ? Constants.majorOutline : Constants.minorOutline
            context?.setLineWidth(strokeWidth)
            
            context?.move(to: CGPoint(x: originX,
                                      y: originY + CGFloat(i) * interColumnsSpacing))
            
            context?.addLine(to: CGPoint(x: originX + size,
                                         y: originY + CGFloat(i) * interColumnsSpacing))
            context?.setStrokeColor(Constants.strokeColor.cgColor)
            context?.strokePath()
        }
    }
    
    func drawInitialValuePairs() {
        guard let initialPairs = dataSource?.initialPairs else {
            return
        }
        
        for pair in initialPairs {
            let rect = rectForColumn(pair.column, andRow: pair.row)
            drawText(pair.value,
                     textColor: Constants.initialValueColor,
                     rect: rect)
        }
    }
    
    func drawSolvedValuePairs() {
         guard let solvedPairs = dataSource?.solvedPairs else {
             return
         }
         
         for pair in solvedPairs {
             let rect = rectForColumn(pair.column, andRow: pair.row)
             drawText(String(pair.value),
                      textColor: Constants.solvedValueColor,
                      rect: rect)
         }
     }
    
    func drawText(_ text: String,
                  textColor: UIColor,
                  font: UIFont = UIFont.systemFont(ofSize: 30.0),
                  rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: rect)
    }
    
    func rectForColumn(_ column: Int, andRow row: Int) -> CGRect {
        let x = originX + CGFloat(column) * interColumnsSpacing
        let y = originY + CGFloat(row) * interRowsSpacing
        
        return CGRect(x: x, y: y, width: interColumnsSpacing, height: interRowsSpacing)
    }
}
