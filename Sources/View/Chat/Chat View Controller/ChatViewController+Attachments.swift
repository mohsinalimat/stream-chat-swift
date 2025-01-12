//
//  ChatViewController+Attachments.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 09/05/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension ChatViewController {
    
    func stopGifsAnimations() {
        visibleAttachmentPreviews { attachmentPreview in
            if attachmentPreview.isGifImage {
                attachmentPreview.imageView.stopAnimatingGif()
            }
        }
    }
    
    func startGifsAnimations() {
        visibleAttachmentPreviews { attachmentPreview in
            if attachmentPreview.isGifImage {
                attachmentPreview.imageView.startAnimatingGif()
            }
        }
    }
    
    private func visibleAttachmentPreviews(action: (_ attachmentPreview: AttachmentPreview) -> Void) {
        return tableView.visibleCells.forEach { cell in
            guard let messageCell = cell as? MessageTableViewCell else {
                return
            }
            
            messageCell.attachmentPreviews.forEach {
                if let attachmentPreview = $0 as? AttachmentPreview {
                    action(attachmentPreview)
                }
            }
        }
    }
}
