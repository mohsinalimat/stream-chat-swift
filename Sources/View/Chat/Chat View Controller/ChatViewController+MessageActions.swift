//
//  ChatViewController+MessageActions.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 09/05/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit

extension ChatViewController {
    
    func showMenu(from cell: UITableViewCell, for message: Message, locationInView: CGPoint? = nil) {
        guard let presenter = channelPresenter else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if presenter.channel.config.reactionsEnabled {
            alert.addAction(.init(title: "Reactions \(Reaction.emoji.first ?? "")", style: .default, handler: { [weak self] _ in
                self?.showReactions(from: cell, in: message, locationInView: locationInView)
            }))
        }
        
        if presenter.canReply {
            alert.addAction(.init(title: "Reply", style: .default, handler: { [weak self] _ in
                self?.showReplies(parentMessage: message)
            }))
        }
        
        if message.canEdit {
            alert.addAction(.init(title: "Edit", style: .default, handler: { [weak self] _ in
                self?.edit(message: message)
            }))
        }
        
        addCopyAction(to: alert, message: message)
        
        if message.canDelete {
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.conformDeleting(message: message)
            }))
        }

        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in }))
        
        present(alert, animated: true)
    }
    
    private func edit(message: Message) {
        if message.text.isEmpty {
            if let command = message.command, let args = message.args {
                composerView.text = "/\(command) \(args)"
            } else {
                return
            }
        } else {
            composerView.text = message.text
        }
        
        channelPresenter?.editMessage = message
        composerView.isEditing = true
        composerView.textView.becomeFirstResponder()
        composerEditingHelperView.sendToBack(for: [composerAddFileView, composerCommandsView])
        composerEditingHelperView.animate(show: true)
    }
    
    private func addCopyAction(to alert: UIAlertController, message: Message) {
        let copyText: String = message.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var copyURL: URL? = nil
        
        if let first = message.attachments.first, let url = first.url {
            copyURL = url
        }
        
        if !copyText.isEmpty || copyURL != nil {
            alert.addAction(.init(title: "Copy", style: .default, handler: { _ in
                if !copyText.isEmpty {
                    UIPasteboard.general.string = copyText
                } else if let url = copyURL {
                    UIPasteboard.general.url = url
                }
            }))
        }
    }
    
    private func conformDeleting(message: Message) {
        var text: String? = nil
        
        if message.textOrArgs.isEmpty {
            if let attachment = message.attachments.first {
                text = attachment.title
            }
        } else {
            text = message.text.count > 100 ? String(message.text.prefix(100)) + "..." : message.text
        }
        
        let alert = UIAlertController(title: "Delete message?", message: text, preferredStyle: .alert)
        
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.channelPresenter?.delete(message: message)
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in }))
        
        present(alert, animated: true)
    }
}
