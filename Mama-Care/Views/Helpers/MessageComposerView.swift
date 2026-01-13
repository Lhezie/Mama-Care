//
//  MessageComposerView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI
import MessageUI

struct MessageComposerView: UIViewControllerRepresentable {
    var recipients: [String]
    var body: String
    var completion: (MessageComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller 
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var completion: (MessageComposeResult) -> Void
        
        init(completion: @escaping (MessageComposeResult) -> Void) {
            self.completion = completion
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            completion(result)
            controller.dismiss(animated: true)
        }
    }
    
    /// Helper to check if the device can send texts
    static func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
}
