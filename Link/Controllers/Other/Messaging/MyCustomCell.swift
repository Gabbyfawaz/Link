//
//  MyCustomCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 02/04/2022.
//

import UIKit
import MessageKit

open class MyCustomCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.red
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
//    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 300, height: 130)
//    }
}


open class MyCustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        //before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
