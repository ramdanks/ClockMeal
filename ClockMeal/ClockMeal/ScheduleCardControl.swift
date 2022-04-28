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
    
    @IBInspectable var indexMealType: Int = 0 { didSet {
        type = MealType.allCases[indexMealType]
    }}
    
    var type: MealType!
    
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
