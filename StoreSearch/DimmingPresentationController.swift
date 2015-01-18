//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Andrew Yap on 18/01/2015.
//  Copyright (c) 2015 Nimblic. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
}
