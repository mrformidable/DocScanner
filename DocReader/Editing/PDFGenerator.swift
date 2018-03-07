//
//  PDFGenerator.swift
//  DocReader
//
//  Created by Michael A on 2018-03-05.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import PDFKit

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
    
    func getPDFdata() -> Data? {
        var data: Data?
        autoreleasepool {
            DispatchQueue.global(qos: .background).async { [weak self] in
                data = self?.pdfDocument.dataRepresentation()
            }
        }
        return data
    }
}






