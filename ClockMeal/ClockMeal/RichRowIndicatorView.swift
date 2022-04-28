import UIKit


@IBDesignable
class RichRowIndicatorView: UIView
{
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBInspectable var indicator: UIImage! { didSet {
        rightImageView.image = indicator
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
        let bundle = Bundle(for: RichRowIndicatorView.self)
        let view = bundle.loadNibNamed(String(describing: RichRowIndicatorView.self), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view)
        return view
    }
}
