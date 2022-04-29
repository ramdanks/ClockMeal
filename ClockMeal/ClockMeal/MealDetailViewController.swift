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
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    var darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    var type: MealType?
    
    var collection: MealCollection?
    
    private var currentData: MealData?
        
    private func contentChanged()
    {
        if (type == .breakfast)
        {
            currentData = collection?.breakfastData
            goalsView1.title = "Good Interval to Dinner"
            goalsView2.title = "Good Interval to Lunch"
            descriptionLabel.text = "Carbohydrates and protein are essential for breakfast. Make sure to eat just enough so your body doesn't get heavy during the day."
        }
        if (type == .lunch)
        {
            currentData = collection?.lunchData
            goalsView1.title = "Good Interval to Breakfast"
            goalsView2.title = "Good Interval to Dinner"
            descriptionLabel.text = "When taking a lunch, make sure to have a good mix of all the good groups that provide macro and micronutrients."
        }
        if (type == .dinner)
        {
            currentData = collection?.dinnerData
            goalsView1.title = "Good Interval to Lunch"
            goalsView2.title = "Good Interval to Breakfast"
            descriptionLabel.text = "Your dinner could be the same as lunch or something different but lesser than lunch. Don't forget macro and micronutrients."
        }
        
        titleLabel?.text = "\(currentData!.type)".capitalized
        planHavingSwitch?.rightSwitch.isOn = currentData?.skipped == false
        timeScheduleControl?.detail = currentData?.time.toString("hh:mm aa")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        contentChanged()
        timePickerView.delegate = self
        darkenView.frame = self.view.frame
        timePickerView.center = self.view.center
        // set initial goals indicator
        let timingIssue = MealRules.issue(collection: collection!, forType: type!, forTime: currentData!.time)
        setIndicatorState(goalsView1, good: timingIssue.prev == false)
        setIndicatorState(goalsView2, good: timingIssue.next == false)
        setIndicatorState(goalsView0, good: currentData?.skipped == false)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        // refresh collection data for unwind segue to ScheduleViewController
        if (currentData?.type == .breakfast) { collection?.breakfastData = currentData! }
        if (currentData?.type == .lunch)     { collection?.lunchData = currentData! }
        if (currentData?.type == .dinner)    { collection?.dinnerData = currentData! }
        // save user defaults
        Settings.mealDataCollection = collection!
        // start dismissing
        super.viewWillDisappear(animated)
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
    
    @IBAction func onHavingMealSwitch(_ sender: RichRowSwitchControl)
    {
        currentData?.skipped = sender.rightSwitch.isOn == false
        setIndicatorState(goalsView0, good: sender.rightSwitch.isOn)
    }
    
    @IBAction func onDoneButton(_ sender: Any)
    {
        dismiss(animated: true)
    }
    
    @IBAction func onTimeScheduleRow(_ sender: RichRowControl)
    {
        displayTimePicker(true)
    }
    
    func onCancelEditing()
    {
        displayTimePicker(false)
    }
    
    func onConfirmEditing(_ date: Date)
    {
        timeScheduleControl.detail = date.toString("hh:mm aa")
        self.currentData?.time = date.toDailyTimeInterval()
        self.collection = timePickerView.data.collection
        // refresh on timing goals
        let timingIssue = MealRules.issue(collection: collection!, forType: type!, forTime: currentData!.time)
        setIndicatorState(goalsView1, good: timingIssue.prev == false)
        setIndicatorState(goalsView2, good: timingIssue.next == false)
        // dismiss time picker
        displayTimePicker(false)
    }
    
    func setIndicatorState(_ indicator: RichRowIndicatorView, good: Bool)
    {
        indicator.rightImageView.tintColor = good ? .systemGreen : .systemRed
        indicator.indicator = UIImage(systemName: good ? "checkmark.square.fill" : "exclamationmark.square.fill")
    }
    
    func displayTimePicker(_ display: Bool)
    {
        if (display)
        {
            timePickerView.data = MealSelection(currentData!.type, collection!)
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
