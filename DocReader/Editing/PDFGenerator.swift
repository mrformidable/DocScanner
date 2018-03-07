//
//  PDFGenerator.swift
//  DocReader
//
//  Created by Michael A on 2018-03-05.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import PDFKit

//enum PaperType: Int {
//    case A4, A3, A2, A1, legal, businessCard
//    static func returnPaperSize () -> PaperType {
//        var paperType: PaperType
//        switch paperType {
//        case .A1:
//            return paperType = .A1
//        default:
//            <#code#>
//        }
//    }
//}

class PDFGenerator: NSObject {
    
    private var pages: [UIImage]
    
    private let pdfDocument = PDFDocument()
    
    private var pdfPage: PDFPage?
    
    var totalPages: Int { return pages.count }
    
    init(pages: [UIImage]) {
        self.pages = pages
        
    }
    
    func generatePDF(withCompletion completion: @escaping (Bool) -> Void) {
        autoreleasepool {
            DispatchQueue.global(qos: .background).async {
                for (index, image) in self.pages.enumerated() {
                    let A4paperSize = CGSize(width: 595, height: 842)
                    let bounds = CGRect.init(origin: .zero, size: A4paperSize)
                    let coreImage = image.cgImage!
                    let editedImage = UIImage(cgImage: coreImage, scale: 0.8, orientation: UIImageOrientation.downMirrored)
                    self.pdfPage = PDFPage(image: editedImage)
                    self.pdfPage?.setBounds(bounds, for: .cropBox)
                    self.pdfDocument.insert(self.pdfPage!, at: index)
                    
                }
                completion(true)
            }
        }
    }
    
    func savePDFFile() {
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        DispatchQueue.global(qos: .background).async {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentDirectory.appendingPathComponent("mypdf.pdf", isDirectory: true)
            self.pdfDocument.write(to: url)
        }
        
        
//        let filePath = "\(documentsPath)/name.pdf"
//        pdfDocument.write(toFile: filePath)
        //pdfDocument.write(toFile: "MyPDF.pdf")
    }
    
    func getSavedFile() {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
       // let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let contents = try? FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        print(contents ?? "nothing saved")

    }
    
    
    func getPDFdata() -> Data? {
        var data: Data?
        autoreleasepool {
            data = pdfDocument.dataRepresentation()
        }
        return data
    }
}






