import Foundation
import UIKit

extension Date
{
    func toString(_ format: String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

protocol TimePickerViewDelegate: AnyObject
{
    func onCancelEditing()
    func onConfirmEditing(_ date: Date)
}

@IBDesignable
class TimePickerView: UIView
{
    weak var delegate: TimePickerViewDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 326, height: 530))
        loadNib()
    }
    
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
        let bundle = Bundle(for: TimePickerView.self)
        let view = bundle.loadNibNamed(String(describing: TimePickerView.self), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view)
        return view
    }
    
    @IBAction func onConfirmButton(_ sender: UIButton)
    {
        delegate?.onConfirmEditing(datePicker.date)
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        delegate?.onCancelEditing()
    }
    
    @IBAction func onTimePicker(_ sender: UIDatePicker)
    {
        timeLabel.text = sender.date.toString("hh:mm aa")
    }
    
}
