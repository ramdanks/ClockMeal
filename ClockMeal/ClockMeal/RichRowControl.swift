import Foundation
import UIKit

@IBDesignable
class RichRowControl: UIControl
{
    @IBOutlet var view: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var previousColors: [UIColor] = []
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.transition(with: self, duration: 0.07, options: .transitionCrossDissolve, animations: {
            self.view.backgroundColor = .label
            for view in self.view.subviews
            {
                if let label = view as? UILabel
                {
                    self.previousColors.append(label.textColor)
                    label.textColor = .systemBackground
                }
                if let imview = view as? UIImageView
                {
                    self.previousColors.append(imview.tintColor)
                    imview.tintColor = .systemBackground
                }
            }
        })
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.view.backgroundColor = .secondarySystemBackground
            for (i, view) in self.view.subviews.enumerated()
            {
                if let label = view as? UILabel         { label.textColor = self.previousColors[i] }
                if let imview = view as? UIImageView    { imview.tintColor = self.previousColors[i] }
            }
        })
        previousColors.removeAll()
        super.touchesEnded(touches, with: event)
    }
}
