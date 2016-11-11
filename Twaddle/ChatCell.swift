//
//  ChatCell.wswift
//  Twaddle
//
//  Created by David Pirih on 11.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    let messageLabel: UILabel = UILabel()
    private let bubbleImageView = UIImageView()
    
    private var outGoingConstraint: NSLayoutConstraint!
    private var incomingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
    
        messageLabel.centerXAnchor.constraint(equalTo: bubbleImageView.centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: bubbleImageView.centerYAnchor).isActive = true
        
        bubbleImageView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 50).isActive = true
        bubbleImageView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor).isActive = true
    
        bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        outGoingConstraint = bubbleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        incomingConstraint = bubbleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func incoming(incoming: Bool) {
        
        if incoming {
            incomingConstraint.isActive = true
            outGoingConstraint.isActive = false
            bubbleImageView.image = bubble.incoming
            
        } else {
            incomingConstraint.isActive = false
            outGoingConstraint.isActive = true
            bubbleImageView.image = bubble.outgoing
        }
    }

}

let bubble = makeBubble()

func makeBubble() -> (incoming: UIImage, outgoing: UIImage) {
    let image = UIImage(named: "MessageBubble")!
    
    let insetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
    let insetsOutging = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
    
    let outgoing = colored(image: image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1).resizableImage(withCapInsets: insetsOutging)
    let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.upMirrored)
    
    let incoming = colored(image: flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha: 1).resizableImage(withCapInsets: insetsIncoming)
    
    return (incoming, outgoing)
}

func colored(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {

    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(in: rect)
    
    context?.setFillColor(UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor)
    context?.setBlendMode(CGBlendMode.sourceAtop)
    context?.fill(rect)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return result
}
