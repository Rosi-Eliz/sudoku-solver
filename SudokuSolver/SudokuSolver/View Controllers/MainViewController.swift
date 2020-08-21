
import UIKit
import Vision
import VisionKit

struct ValueData {
    let value: String
    let column: Int
    let row: Int
    
    init(value: String, column: Int, row: Int) {
        self.value = (1...9).map({String($0)}).contains(value) ? value : "1"
        self.column = column
        self.row = row
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var sudokuView: SudokuView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    
    var scannedData: [ValueData] = [] {
        didSet {
            solveButton.isEnabled = !scannedData.isEmpty
        }
    }
    var solvedData: [ValueData] = []
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue",
                                                         qos: .userInitiated,
                                                         attributes: [],
                                                         autoreleaseFrequency: .workItem)
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var path = [ValuePoint(x: 0, y: 0)]
//        path.append(ValuePoint(x: 1, y: 1))
//
//        let pathPtr = UnsafePointer<ValuePoint>(path)
//
//        let t = f(pathPtr)!
//
//        let buffer = Array(UnsafeBufferPointer(start: t, count: 2))
    
        
        solveButton.isEnabled = false
        setupVision()
    }
    
    func convert<T, Z>(length: Int, data: UnsafePointer<Z>, _: T.Type) -> [T] {
        let numItems = length/MemoryLayout<Z>.stride
        let buffer = data.withMemoryRebound(to: T.self, capacity: numItems) {
            UnsafeBufferPointer(start: $0, count: numItems)
        }
        return Array(buffer)
    }
  
    func processScannedData(_ scannedData: [ValueData]) {
        self.scannedData = scannedData
        let dataSource = SudokuView.DataSource(initialPairs: scannedData,
                                               solvedPairs: [])
        sudokuView.setDataSource(dataSource)
    }
    
    @IBAction func scanButtonAction(_ sender: Any) {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    @IBAction func solveButtonAction(_ sender: Any) {
        let inputParameter = scannedData.map({ ValuePoint(row: Int32($0.row), column: Int32($0.column), value: Int32($0.value) ?? 0 ) })
        
        let pathPtr = UnsafePointer<ValuePoint>(inputParameter)
        let bufferData = solve(pathPtr, Int32(inputParameter.count))
        
        let buffer = Array(UnsafeBufferPointer(start: bufferData, count: 81))
        
        let solvedPairs = buffer.filter { solvedPoint -> Bool in
            return !scannedData.contains(where: { $0.row == solvedPoint.row && $0.column == solvedPoint.column })
        }
        
        solvedData = solvedPairs.map({ ValueData(value: String($0.value), column: Int($0.column), row: Int($0.row)) })
        
        let dataSource = SudokuView.DataSource(initialPairs: scannedData,
                                               solvedPairs: solvedData)
        sudokuView.setDataSource(dataSource)
    }
}

extension MainViewController: VNDocumentCameraViewControllerDelegate {
    
    func closedRangeForElementsCount(_ count: Int, reversedIndex: Bool = false) -> [(ClosedRange<CGFloat>, Int)] {
         var ranges: [(ClosedRange<CGFloat>, Int)] = []
         
         let absoluteLength: CGFloat = 1.0/CGFloat(count);
         for i in 0..<count {
             let leftBound = CGFloat(i) * absoluteLength
             let rightBound = leftBound + absoluteLength
             ranges.append((leftBound...rightBound, reversedIndex ? count - (i + 1) : i))
         }
         return ranges
     }
    
      private func setupVision() {
            
            let horizontalRange = closedRangeForElementsCount(9)
            let verticalRange = closedRangeForElementsCount(9, reversedIndex: true)
            textRecognitionRequest = VNRecognizeTextRequest { [weak self] (request, error)  in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
         
                var data: [ValueData] = []
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { return }
                    
                    
                    
                    let candidateCenter = observation.boundingBox.absoluteCenter
                    
                    var text = topCandidate.string
                    if topCandidate.string == "7" {
                        var oneCount = 0
                        for candindate in observation.topCandidates(9) {
                            if (candindate.string == "1")
                            {
                                oneCount += 1
                            }
                        }
                        
                        if oneCount > 5 {
                            text = "1"
                        }
                    }
                    
                    if text.count > 1 {
                        let trimmedText = text.trimmingCharacters(in: .whitespaces)
                        let width = observation.boundingBox.width / CGFloat(trimmedText.count)
                        let centerY = observation.boundingBox.origin.y + observation.boundingBox.height / 2
                        let originX = observation.boundingBox.origin.y
                        
                        for (index, char) in trimmedText.enumerated() {
                            let centerX = originX + CGFloat(index) * (width/CGFloat(text.count))
                            let center = CGPoint(x: centerX, y: centerY)
                            
                            if let horizontalIndex = horizontalRange.first(where: { $0.0.contains(center.x) })?.1,
                                let verticalIndex = verticalRange.first(where: { $0.0.contains(center.y) })?.1 {
                                data.append(ValueData(value: String(char), column: horizontalIndex, row: verticalIndex))
                            }
                        }
                        
                    } else {
                        if let horizontalIndex = horizontalRange.first(where: { $0.0.contains(candidateCenter.x) })?.1,
                            let verticalIndex = verticalRange.first(where: { $0.0.contains(candidateCenter.y) })?.1 {
                            data.append(ValueData(value: text, column: horizontalIndex, row: verticalIndex))
                        }
                    }
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.processScannedData(data)
                }
            }

            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.customWords = (1...9).map({ String($0) })
        }
        
        private func processImage(_ image: UIImage) {
            recognizeTextInImage(image)
        }
        
        private func recognizeTextInImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            textRecognitionWorkQueue.async {
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try requestHandler.perform([self.textRecognitionRequest])
                } catch {
                    print(error)
                }
            }
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount >= 1 else {
                controller.dismiss(animated: true)
                return
            }
            
            let originalImage = scan.imageOfPage(at: 0)
            let newImage = compressedImage(originalImage)
            controller.dismiss(animated: true)
            
            processImage(newImage)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print(error)
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func compressedImage(_ originalImage: UIImage) -> UIImage {
            guard let imageData = originalImage.jpegData(compressionQuality: 1),
                let reloadedImage = UIImage(data: imageData) else {
                    return originalImage
            }
            return reloadedImage
        }
}

extension CGRect {
    var absoluteCenter: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }
}
