import Foundation
import UIKit

@IBDesignable
class RichRowControl: UIControl
{
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBInspectable var detail: String! { didSet {
        detailLabel.text = detail
    }}
    
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
        let bundle = Bundle(for: RichRowControl.self)
        let view = bundle.loadNibNamed(String(describing: RichRowControl.self), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view)
        return view
    }
}
