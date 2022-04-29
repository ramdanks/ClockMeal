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
}
