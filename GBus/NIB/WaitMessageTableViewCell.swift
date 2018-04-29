//
//  WaitMessageTableViewCell.swift
//  GBus
//
//  Created by Krisztina Nagy on 29/04/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

protocol WaitMessageTableViewCellDelegate: class {
    func acceptUserWaitMessage(row: Int)
    func declineUserWaitMessage(row: Int)
}

class WaitMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    weak var delegate: WaitMessageTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptWaitMessage(_ sender: UIButton) {
        print("Ez a gomb pipa szama: \(sender.tag)")
        delegate?.acceptUserWaitMessage(row: sender.tag)
    }
    
    @IBAction func declineWaitMessage(_ sender: UIButton) {
        print("Ez a gomb x szama: \(sender.tag)")
        delegate?.declineUserWaitMessage(row: sender.tag)
    }
    
}
