import UIKit

class MealDetailViewController: UIViewController, TimePickerViewDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var planHavingSwitch: RichRowSwitchControl!
    @IBOutlet weak var timeScheduleControl: RichRowControl!
    
    @IBOutlet weak var goalsView0: RichRowIndicatorView!
    @IBOutlet weak var goalsView1: RichRowIndicatorView!
    @IBOutlet weak var goalsView2: RichRowIndicatorView!
    
    var timePickerView: TimePickerView = {
        let view = TimePickerView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    var darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.75
        return view
    }()
    
    var type: MealType?
    var imageShowcase: UIImage?
    var collection: MealCollection!
    
    private var currentData: MealData?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        contentChanged()
        timePickerView.delegate = self
        darkenView.frame = self.view.frame
        timePickerView.center = self.view.center
        
        // set initial goals indicator
        setIndicatorState(goalsView1, good: currentData!.issues.contains(.previousMeal) == false)
        setIndicatorState(goalsView2, good: currentData!.issues.contains(.nextMeal) == false)
        setIndicatorState(goalsView0, good: currentData!.scheduled)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        // refresh collection data for unwind segue to ScheduleViewController
        if (currentData?.type == .breakfast) { collection.breakfastData  = currentData! }
        if (currentData?.type == .lunch)     { collection.lunchData      = currentData! }
        if (currentData?.type == .dinner)    { collection.dinnerData     = currentData! }
        // start dismissing
        super.viewWillDisappear(animated)
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
    
    @IBAction func onHavingMealSwitch(_ sender: RichRowSwitchControl)
    {
        currentData?.scheduled = sender.rightSwitch.isOn
        setIndicatorState(goalsView0, good: sender.rightSwitch.isOn)
    }
    
    @IBAction func onDoneButton(_ sender: Any)
    {
        dismiss(animated: true)
    }
    
    @IBAction func onTimeScheduleRow(_ sender: RichRowControl)
    {
        timePickerView.goalsView0.title = self.goalsView1.title
        timePickerView.goalsView1.title = self.goalsView2.title
        timePickerView.goalsView0.rightImageView.image = self.goalsView1.rightImageView.image
        timePickerView.goalsView1.rightImageView.image = self.goalsView2.rightImageView.image
        timePickerView.goalsView0.rightImageView.tintColor = self.goalsView1.rightImageView.tintColor
        timePickerView.goalsView1.rightImageView.tintColor = self.goalsView2.rightImageView.tintColor
        
        let time = currentData?.time
        let dateFormatter = DateFormatter()
        let dateString = time?.toString("hh:mm aa") ?? "?"
        dateFormatter.dateFormat = "hh:mm aa"
        timePickerView.datePicker.date = dateFormatter.date(from: dateString) ?? Date()
        timePickerView.timeLabel.text = dateString
        
        displayTimePicker(true)
    }
    
    func onCancelEditing(_ sender: TimePickerView)
    {
        displayTimePicker(false)
    }
    
    func onConfirmEditing(_ sender: TimePickerView, date: Date)
    {
        timeScheduleControl.detail = date.toString("hh:mm aa")
        
        let issues = MealRules.issues(
            collection: collection,
            forType: currentData!.type,
            forTime: date.toDailyTimeInterval()
        )
        
        self.currentData?.issues = issues
        self.currentData?.time = date.toDailyTimeInterval()
        
        // refresh on timing goals
        setIndicatorState(goalsView1, good: issues.contains(.previousMeal) == false)
        setIndicatorState(goalsView2, good: issues.contains(.nextMeal) == false)
        
        // dismiss time picker
        displayTimePicker(false)
    }
    
    func onDateChanged(_ sender: TimePickerView, date: Date)
    {
        sender.timeLabel.text = date.toString("hh:mm aa")
        
        let issues = MealRules.issues(
            collection: collection,
            forType: currentData!.type,
            forTime: date.toDailyTimeInterval()
        )
        
        let prevIssue = issues.contains(.previousMeal)
        let nextIssue = issues.contains(.nextMeal)
        
        sender.goalsView0.rightImageView.tintColor = prevIssue ? .systemRed : .systemGreen
        sender.goalsView0.indicator = UIImage(systemName: prevIssue ? "exclamationmark.square.fill" : "checkmark.square.fill")
        
        sender.goalsView1.rightImageView.tintColor = nextIssue ? .systemRed : .systemGreen
        sender.goalsView1.indicator = UIImage(systemName: nextIssue ? "exclamationmark.square.fill" : "checkmark.square.fill")
    }
    
    func setIndicatorState(_ indicator: RichRowIndicatorView, good: Bool)
    {
        indicator.rightImageView.tintColor = good ? .systemGreen : .systemRed
        indicator.indicator = UIImage(systemName: good ? "checkmark.square.fill" : "exclamationmark.square.fill")
    }
    
    private func contentChanged()
    {
        if (type == .breakfast)
        {
            currentData = collection.breakfastData
            goalsView1.title = "Good Interval to Dinner"
            goalsView2.title = "Good Interval to Lunch"
            descriptionLabel.text = "Carbohydrates and protein are essential for breakfast. Make sure to eat just enough so your body doesn't get heavy during the day."
        }
        if (type == .lunch)
        {
            currentData = collection.lunchData
            goalsView1.title = "Good Interval to Breakfast"
            goalsView2.title = "Good Interval to Dinner"
            descriptionLabel.text = "When taking a lunch, make sure to have a good mix of all the good groups that provide macro and micronutrients."
        }
        if (type == .dinner)
        {
            currentData = collection.dinnerData
            goalsView1.title = "Good Interval to Lunch"
            goalsView2.title = "Good Interval to Breakfast"
            descriptionLabel.text = "Your dinner could be the same as lunch or something different but lesser than lunch. Don't forget macro and micronutrients."
        }
        imageView.image = imageShowcase
        titleLabel?.text = "\(currentData!.type)".capitalized
        planHavingSwitch?.rightSwitch.isOn = currentData!.scheduled
        timeScheduleControl?.detail = currentData!.time.toString("hh:mm aa")
    }
    
    func displayTimePicker(_ display: Bool)
    {
        if (display)
        {
            UIView.transition(
                with: self.view,
                duration: 0.25,
                options: [.transitionCrossDissolve],
                animations: {
                    self.view.addSubview(self.darkenView)
                    self.view.addSubview(self.timePickerView)
                },
                completion: nil
            )
        }
        else
        {
            UIView.transition(
                with: self.view,
                duration: 0.25,
                options: [.transitionCrossDissolve],
                animations: {
                    self.timePickerView.removeFromSuperview()
                    self.darkenView.removeFromSuperview()
                },
                completion: nil
            )
        }
    }
}
