//
//  FileManager.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/3/22.
//

import Foundation
import UIKit

public extension FileManager {
    static var documentsURL: URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("files")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return nil
                }
            }
            return filePath
        }
        return nil
    }

    /// save file to Document directory
    static func saveDocument(for filePickerUrl: URL?) -> URL? {
        guard let url = filePickerUrl else {
            return nil
        }
        
        guard let documentsUrl = documentsURL else {
            return nil
        }

        var editedUrl = documentsUrl
            .appendingPathComponent(url.lastPathComponent)

        do {
            let success = url.startAccessingSecurityScopedResource()
            var data = try Data(contentsOf: url)

            // convert heic to png if needed
            if url.pathExtension.lowercased() == "heic",
               let image = UIImage(data: data),
               let pngData = image.pngData() {
                data = pngData
                editedUrl.deletePathExtension()
                editedUrl.appendPathExtension("png")
            }

            try data.write(to: editedUrl)
            
            if success {
                url.stopAccessingSecurityScopedResource()
            }
        } catch {
            print(error)
        }

        return editedUrl
    }
    
    static func saveDocumentImage(image: UIImage) -> URL? {
        guard let documentsUrl = documentsURL else {
            return nil
        }
        
        let editedUrl = documentsUrl
            .appendingPathComponent("IMAGE")
            .appendingPathExtension("png")
        
        do {
            if let data = image.pngData() {
                try data.write(to: editedUrl)
            }
        } catch {
            print(error)
        }

        return editedUrl
    }
}
