//
//  ALContact+Extension.swift
//  Axiata
//
//  Created by Mukesh Thawani on 01/06/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation
import Applozic

extension ALContact: ContactProtocol {
    var friendUUID: String? {
        return self.userId
    }

    var friendDisplayImgURL: URL? {
        guard let imageUrl = self.contactImageUrl, let url = URL(string: imageUrl) else {
        return nil
        }
        return url
    }

    var friendProfileName: String? {
        return self.displayName
    }

    var friendMood: String? {
        return nil
    }
}
