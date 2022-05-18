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
    func toString(_ format: String, timeZone: TimeZone) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
    
    /// will only take hours and minutes from date and turns it into TimeInterval, (HH:mm)
    /// it will results valu from 0 -> 24 * 60 * 60
    func toDailyTimeInterval() -> TimeInterval
    {
        let hours = Double(self.toString("HH"))!
        let mins = Double(self.toString("mm"))!
        return hours * 60 * 60 + mins * 60
    }
}

@objc protocol TimePickerViewDelegate: AnyObject
{
    func onCancelEditing(_ sender: TimePickerView)
    func onDateChanged(_ sender: TimePickerView, date: Date)
    func onConfirmEditing(_ sender: TimePickerView, date: Date)
}

@IBDesignable
class TimePickerView: UIView
{
    @IBOutlet weak var delegate: TimePickerViewDelegate?
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var goalsView0: RichRowIndicatorView!
    
    @IBOutlet weak var goalsView1: RichRowIndicatorView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 330, height: 530))
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
        delegate?.onConfirmEditing(self, date: datePicker.date)
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        delegate?.onCancelEditing(self)
    }
    
    @IBAction func onTimePicker(_ sender: UIDatePicker)
    {
        delegate?.onDateChanged(self, date: sender.date)
    }
}
