//
//  MensaSelectionController.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 05.06.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

class MensaSelectionController: UITableViewController {
  private var disabledMensaNames : NSMutableArray? = nil
  private let tagOffset = 2440974
  
  override func viewDidLoad() {
    super.viewDidLoad()
    disabledMensaNames = Globals.disabledMensaNames()?.mutableCopy() as? NSMutableArray
    if disabledMensaNames == nil {
      disabledMensaNames = NSMutableArray(capacity: Globals.mensas.count)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Globals.mensas.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MensaCell", for: indexPath) as! MensaCell
    let mensa = Globals.mensas[indexPath.row]
    cell.nameLabel.text = mensa.name
    
    let off = disabledMensaNames != nil && disabledMensaNames!.contains(mensa.name)
    cell.enableSwitch.isOn = !off
    cell.enableSwitch.tag = tagOffset + indexPath.row
    
    return cell
  }
  
  @IBAction func dismissSelection(sender: AnyObject) {
    if disabledMensaNames != nil {
      Globals.setDisabledMensas(names: disabledMensaNames!)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func changedEnableValue(sender: UISwitch) {
    let mensa = Globals.mensas[sender.tag - tagOffset]
    if sender.isOn {
      disabledMensaNames?.remove(mensa.name)
    } else {
      disabledMensaNames?.add(mensa.name)
    }
  }
}

class MensaCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var enableSwitch: UISwitch!
  
}
