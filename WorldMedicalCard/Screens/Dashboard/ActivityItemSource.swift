//
//  ActivityItemSource.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/17/22.
//

import LinkPresentation

class ActivityItemSource: NSObject {

    var title: String
    var metaData: Any //to be shared
    
    init(title: String, metaData: Any) {
        self.title = title
        self.metaData = metaData
    }
}
extension ActivityItemSource: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return metaData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return metaData
    }
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = title
        if let image = self.metaData as? UIImage {
            metaData.iconProvider = NSItemProvider(object: image)
        } else if let url = self.metaData as? URL {
            metaData.iconProvider = NSItemProvider(contentsOf: url)
        }
        return metaData
    }
}
