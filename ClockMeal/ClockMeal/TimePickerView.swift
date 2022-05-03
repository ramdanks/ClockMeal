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

protocol TimePickerViewDelegate: AnyObject
{
    func onCancelEditing()
    func onConfirmEditing(_ date: Date, issues: [MealRules.Issue])
}

@IBDesignable
class TimePickerView: UIView
{
    weak var delegate: TimePickerViewDelegate?
    
    var data: MealSelection! { didSet {
        var time: TimeInterval!
        if (data.type == .breakfast)
        {
            time = data.collection.breakfastData.time
            goalsView0.title = "Good Interval to Dinner"
            goalsView1.title = "Good Interval to Lunch"
        }
        if (data.type == .lunch)
        {
            time = data.collection.lunchData.time
            goalsView0.title = "Good Interval to Breakfast"
            goalsView1.title = "Good Interval to Dinner"
        }
        if (data.type == .dinner)
        {
            time = data.collection.dinnerData.time
            goalsView0.title = "Good Interval to Lunch"
            goalsView1.title = "Good Interval to Breakfast"
        }
        let dateFormatter = DateFormatter()
        let dateString = time.toString("hh:mm aa")
        dateFormatter.dateFormat = "hh:mm aa"
        datePicker.date = dateFormatter.date(from: dateString) ?? Date()
        timeLabel.text = dateString
        updateGoalsView()
    }}
    
    private var issues: [MealRules.Issue]!
    
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
        delegate?.onConfirmEditing(datePicker.date, issues: issues)
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        delegate?.onCancelEditing()
    }
    
    @IBAction func onTimePicker(_ sender: UIDatePicker)
    {
        updateGoalsView()
        timeLabel.text = sender.date.toString("hh:mm aa")
    }
    
    func updateGoalsView()
    {
        issues = MealRules.issues(
            collection: data.collection,
            forType: data.type,
            forTime: datePicker.date.toDailyTimeInterval()
        )
        
        let prevIssue = issues.contains(.previousMeal)
        let nextIssue = issues.contains(.nextMeal)
        
        goalsView0.rightImageView.tintColor = prevIssue ? .systemRed : .systemGreen
        goalsView0.indicator = UIImage(systemName: prevIssue ? "exclamationmark.square.fill" : "checkmark.square.fill")
        
        goalsView1.rightImageView.tintColor = nextIssue ? .systemRed : .systemGreen
        goalsView1.indicator = UIImage(systemName: nextIssue ? "exclamationmark.square.fill" : "checkmark.square.fill")
    }
}
