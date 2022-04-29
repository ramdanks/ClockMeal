import UIKit

@IBDesignable
class ScheduleCardControl: UIControl
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel0: UILabel!
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var info0: String! { didSet {
        infoLabel0.text = info0
    }}
    
    @IBInspectable var info1: String! { didSet {
        infoLabel1.text = info1
    }}
    
    @IBInspectable var image: UIImage! { didSet {
        imageView.image = image
    }}
    
    var data: MealData! { didSet {
        info1 = data.time.toString("hh:mm aa")
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
        let bundle = Bundle(for: ScheduleCardControl.self)
        let view = bundle.loadNibNamed(String(describing: ScheduleCardControl.self), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view)
        return view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.alpha = 0.8
        })
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        })
        super.touchesEnded(touches, with: event)
    }
}
