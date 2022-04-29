import UIKit

class HomeViewController: UIViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var mealTitleLabel: UILabel!
    @IBOutlet weak var timerHourLabel: UILabel!
    @IBOutlet weak var timerMinuteLabel: UILabel!
    @IBOutlet weak var timerSeperatorLabel: UILabel!
    @IBOutlet weak var timerDescLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scheduleIssue: RichRowControl!
    
    @IBOutlet weak var breakfastDetailView: RichRowDetailView!
    @IBOutlet weak var lunchDetailView: RichRowDetailView!
    @IBOutlet weak var dinnerDetailView: RichRowDetailView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        timerHourLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 62.0, weight: .regular)
        timerMinuteLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 62.0, weight: .regular)
        
        let date = Date()
        let calendar = Calendar.current
        let hour: TimeInterval = TimeInterval(calendar.component(.hour, from: date))
        let minutes: TimeInterval = TimeInterval(calendar.component(.minute, from: date))
        
        let now = hour * 60 * 60 + minutes * 60
        
        let collection = Settings.mealDataCollection
        var session = Settings.currentSession
        if (session == nil)
        {
            let a = now.rangeCappedDaily(to: collection.breakfastData.time)
            let b = now.rangeCappedDaily(to: collection.lunchData.time)
            let c = now.rangeCappedDaily(to: collection.dinnerData.time)
            let closest = [a, b, c].min()
            if (closest == a) { session = .breakfast }
            if (closest == b) { session = .lunch }
            if (closest == c) { session = .dinner }
            Settings.currentSession = session
        }
        
        var data: MealData!
        if (session == .breakfast) { data = collection.breakfastData }
        if (session == .lunch)     { data = collection.lunchData }
        if (session == .dinner)    { data = collection.dinnerData }
        mealTitleLabel.text = "\(data.type)".capitalized

        // check if different day
        let responses = Settings.responses
        if (responses.isEmpty == false)
        {
            let lastDate = responses.last!
            let diff = Calendar.current.dateComponents([ .day ], from: date, to: lastDate.date)
            // if different day then remove all respond
            if (diff.day != 0)
            {
                Settings.responses.removeAll()
                updateRespond(type: .breakfast, response: nil)
                updateRespond(type: .lunch, response: nil)
                updateRespond(type: .dinner, response: nil)
            }
            // retrieve saved response
            else
            {
                for response in responses
                {
                    updateRespond(type: response.type, response: response)
                }
            }
        }
        
        Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(HomeViewController.counter),
            userInfo: nil,
            repeats: true
        )
    }
    
    @IBAction func onScheduleIssue(_ sender: RichRowControl)
    {
        let tabBar = self.parent as? MyTabBarController
        tabBar?.selectedIndex = 2 // to schedule tab view
    }
    
    @IBAction func onThemeChanged(_ sender: UISegmentedControl)
    {
        let lightThemeIndex = 0
        let darkThemeIndex = 1
        
        if (sender.selectedSegmentIndex == lightThemeIndex)
        {
            let selectedImage = UIImage(systemName: "sun.max.fill")
            let unselectedImage = UIImage(systemName: "moon")
            
            sender.setImage(selectedImage, forSegmentAt: lightThemeIndex)
            sender.setImage(unselectedImage, forSegmentAt: darkThemeIndex)
        }
        else if (sender.selectedSegmentIndex == darkThemeIndex)
        {
            let selectedImage = UIImage(systemName: "moon.fill")
            let unselectedImage = UIImage(systemName: "sun.max")
            
            sender.setImage(selectedImage, forSegmentAt: darkThemeIndex)
            sender.setImage(unselectedImage, forSegmentAt: lightThemeIndex)
        }
    }
    
    
    @IBAction func onTakingMealButton(_ sender: UIButton)
    {
        let titleAlert = "Take a Meal"
        var alert: UIAlertController!
        if (Settings.responses.last?.type == .dinner)
        {
            alert = UIAlertController(title: titleAlert, message: "You have responded enough for today. Comeback again tomorrow!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        }
        else
        {
            alert = UIAlertController(title: titleAlert, message: "I declare that either i had a meal recently or going to take meal now", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Check In", style: .default, handler: { action in
                self.nextSession(skip: false)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSkipMealButton(_ sender: UIButton)
    {
        let titleAlert = "Skip Meal"
        var alert: UIAlertController!
        if (Settings.responses.last?.type == .dinner)
        {
            alert = UIAlertController(title: titleAlert, message: "You have responded enough for today. Comeback again tomorrow!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        }
        else
        {
            alert = UIAlertController(title: titleAlert, message: "Skipping a meal introduce inconsistency which can be harmful than eating less or more with consistent timings. Are you sure you want to skip this session?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I Understand The Risk", style: .default, handler: { action in
                self.nextSession(skip: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func nextSession(skip: Bool)
    {
        let currTypeSession = Settings.currentSession!
        let respond = Response(type: currTypeSession, date: Date(), skip: skip)
        Settings.responses.append(respond)
        updateRespond(type: currTypeSession, response: respond)
        
        var nextTypeSession: MealType!
        if (currTypeSession == .breakfast)
        {
            nextTypeSession = .lunch
            imageView.image = UIImage(named: "day")
        }
        if (currTypeSession == .lunch)
        {
            nextTypeSession = .dinner
            imageView.image = UIImage(named: "night")
        }
        if (currTypeSession == .dinner)
        {
            nextTypeSession = .breakfast
            imageView.image = UIImage(named: "morning")
        }
        
        mealTitleLabel.text = "\(nextTypeSession!)".capitalized
        Settings.currentSession = nextTypeSession
    }
    
    func updateRespond(type: MealType, response: Response?)
    {
        var detailString = "Waiting"
        
        if (response != nil)
            { detailString = response!.skip ? "Skipped" : response!.date.toString("hh:mm aa") }
        
        if (type == .breakfast)
            { self.breakfastDetailView.detail = detailString }
        if (type == .lunch)
            { self.lunchDetailView.detail = detailString }
        if (type == .dinner)
            { self.dinnerDetailView.detail = detailString }
    }
    
    @objc func counter()
    {
        let date = Date()
        let calendar = Calendar.current
        let hour: TimeInterval = TimeInterval(calendar.component(.hour, from: date))
        let minutes: TimeInterval = TimeInterval(calendar.component(.minute, from: date))
        
        // this is barbaric!
        scheduleIssue.detail = "\(issueCountTotalSparta())"
        
        let now = hour * 60 * 60 + minutes * 60
        var counter: TimeInterval!
        
        let collection = Settings.mealDataCollection
        let session = Settings.currentSession
        
        var myData: MealData!
        if (session == .breakfast) { myData = collection.breakfastData }
        if (session == .lunch)     { myData = collection.lunchData }
        if (session == .dinner)    { myData = collection.dinnerData }
        
        // upcming next day
        if (session == .breakfast && Settings.responses.last?.type == .dinner)
        {
            timerDescLabel.text = "Will be going in:"
            counter = now.rangeCappedDaily(to: collection.breakfastData.time)
        }
        // upcoming meal
        else if (now < myData.time)
        {
            timerDescLabel.text = "Will be going in:"
            counter = myData.time - now
        }
        // late for meal
        else
        {
            timerDescLabel.text = "You were late for:"
            counter = now - myData.time
        }
        timerHourLabel.text = counter.toString("HH")
        timerMinuteLabel.text = counter.toString("mm")
        timerSeperatorLabel.isHidden = !timerSeperatorLabel.isHidden
    }
    
}
