//
//  RichRowSwitchControl.swift
//  ClockMeal
//
//  Created by Ramadhan Kalih Sewu on 28/04/22.
//

import UIKit

@IBDesignable
class RichRowSwitchControl: UIControl
{
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightSwitch: UISwitch!
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var logo: UIImage! { didSet {
        logoImageView.image = logo
    }}
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        loadNib()
    }
    
    @discardableResult func loadNib() -> UIView
    {
        let bundle = Bundle(for: RichRowSwitchControl.self)
        let view = bundle.loadNibNamed(String(describing: RichRowSwitchControl.self), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view)
        return view
    }
    
    @IBAction func onSwitchValueChange(_ sender: UISwitch)
    {
        sendActions(for: .valueChanged)
    }
}
