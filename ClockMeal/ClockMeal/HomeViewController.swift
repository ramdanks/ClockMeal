import UIKit

class HomeViewController: UIViewController
{
    enum State { case goingToday, lateToday, goingTomorrow, noSchedule }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var bottomAlertLabel: UILabel!
    @IBOutlet weak var sessionDoneView: UIView!
    
    @IBOutlet weak var takingMealButton: UIButton!
    @IBOutlet weak var skipMealButton: UIButton!
    
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
    
    var session: MealType?
    var state: State?
    var todayMajorMealResponse: [Response] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        timerHourLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 62.0, weight: .regular)
        timerMinuteLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 62.0, weight: .regular)
        
        let date = Date()
        
        var currSession: MealType? = nil
        
        if (Calendar.current.isDateInToday(Settings.lastLogin))
        {
            let responses = Settings.responses
            // update today's session
            for response in responses.reversed()
            {
                if (Calendar.current.isDate(date, inSameDayAs: response.date) == false) { break }
                if (response.type != .snack) { todayMajorMealResponse.append(response) }
            }
            // find meal session based on last responses
            let lastMealSession = todayMajorMealResponse.max(by: { $0.type.rawValue > $1.type.rawValue })?.type
            currSession = whatNextSession(lastMealSession, schedule: Settings.mealDataCollection)
        }
        else
        {
            Settings.lastLogin = Date.now
            let schedule = Settings.upcomingSchedule
            let scheduleList = [schedule.breakfastData, schedule.lunchData, schedule.dinnerData]
            
            Settings.mealDataCollection = schedule
            currSession = scheduleList.first(where: { $0.scheduled })?.type ?? .breakfast
        }
        
        updateViewOnSession(newSession: currSession!, newState: .goingToday)
        
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
        let alert = UIAlertController(
            title: "Take a Meal",
            message:"I declare that either i had a meal recently or going to take meal now",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Check In", style: .default, handler: { [self] action in
            
            let respond = Response(type: session!, date: Date(), skip: false)
            todayMajorMealResponse.append(respond)
            Settings.responses.append(respond)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSkipMealButton(_ sender: UIButton)
    {
        let alert = UIAlertController(
            title: "Skip Meal",
            message: "Skipping a meal introduce inconsistency which can be harmful than eating less ormore with consistent timings. Are you sure you want to skip this session?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "I Understand The Risk", style: .default, handler: { [self] action in
            
            let respond = Response(type: session!, date: Date(), skip: true)
            todayMajorMealResponse.append(respond)
            Settings.responses.append(respond)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func whatNextSession(_ session: MealType?, schedule: MealCollection) -> MealType?
    {
        if (session == .snack) { return .breakfast }
        
        let scheduleList = [ schedule.breakfastData, schedule.lunchData, schedule.dinnerData ]
        let sessionList: [MealType] = [ .breakfast, .lunch, .dinner ]
        
        if (scheduleList.contains(where: { $0.scheduled }))
        {
            var nextSession = session
            while (true)
            {
                nextSession = nextSessionRaw(nextSession)
                let scheduleIdx = sessionList.firstIndex(where: { $0 == nextSession })!
                let schedule = scheduleList[scheduleIdx]
                if (schedule.scheduled) { return schedule.type }
            }
        }
        
        return nil
    }
    
    func isTodayComplete() -> Bool
    {
        let todaySchedule = Settings.mealDataCollection
        let todaySchedules = [todaySchedule.breakfastData, todaySchedule.lunchData, todaySchedule.dinnerData]
        
        let todayLastMealResponse = todayMajorMealResponse.max(by: { $0.type.rawValue < $1.type.rawValue })
        
        if (todaySchedules.contains(where: { $0.scheduled }))
        {
            var nextSession = todayLastMealResponse?.type
            while (nextSession != .dinner)
            {
                nextSession = nextSessionRaw(nextSession)
                let schedule = todaySchedules.first(where: { $0.type == nextSession })!
                if (schedule.scheduled) { return false }
            }
        }
        
        return true
    }
    
    func nextSessionRaw(_ session: MealType?) -> MealType
    {
        if (session != nil)
        {
            if (session == .breakfast)  { return .lunch }
            if (session == .lunch)      { return .dinner }
            if (session == .dinner)     { return .breakfast }
        }
        return .breakfast
    }
    
    func updateViewOnSession(newSession: MealType, newState: State)
    {
        if (session != newSession)
        {
            mealTitleLabel.text = "\(newSession)".capitalized
            if (newSession == .breakfast)  { imageView.image = UIImage(named: "morning") }
            if (newSession == .lunch)      { imageView.image = UIImage(named: "day") }
            if (newSession == .dinner)     { imageView.image = UIImage(named: "night") }
        }
        
        if (state != newState)
        {
            var enableResponse = false
            if (newState == .lateToday)
            {
                timerDescLabel.text = "You were late for:"
                enableResponse = true
            }
            else if (newState == .goingToday)
            {
                timerDescLabel.text = "Will be going in:"
                enableResponse = true
            }
            else if (newState == .goingTomorrow)
            {
                timerDescLabel.text = "Will be going in:"
                bottomAlertLabel.text = "Thank your response! Please come back again tomorrow"
                enableResponse = false
            }
            else if (newState == .noSchedule)
            {
                timerDescLabel.text = "Unknown time left:"
                bottomAlertLabel.text = "You have not set up any schedule. Go to schedule tab and set some"
                enableResponse = false
            }
            sessionDoneView.isHidden = enableResponse
            skipMealButton.isHidden = !enableResponse
            takingMealButton.isHidden = !enableResponse
        }
        
        state = newState
        session = newSession
    }
    
    @objc func counter()
    {
        let todaySchedule = Settings.mealDataCollection
        let todaySchedules = [todaySchedule.breakfastData, todaySchedule.lunchData, todaySchedule.dinnerData]
        
        let upcomingSchedule = Settings.upcomingSchedule
        let upcomingSchedules = [upcomingSchedule.breakfastData, upcomingSchedule.lunchData, upcomingSchedule.dinnerData]
        
        var currSession = session!
        var currState: State!
        
        let views = [breakfastDetailView, lunchDetailView, dinnerDetailView]
        
        var counter: TimeInterval = 0
        
        let issueCount =
            todaySchedule.breakfastData.issues.count +
            todaySchedule.lunchData.issues.count +
            todaySchedule.dinnerData.issues.count
        
        scheduleIssue.detail = issueCount == 0 ? "None" : "\(issueCount)"
        
        let now = Date.now
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let nowTimeInterval = TimeInterval(hour * 60 * 60 + minute * 60)
        
        let todayLastMealResponse = todayMajorMealResponse.max(by: { $0.type.rawValue < $1.type.rawValue })
        
        if (isTodayComplete())
        {
            let nextSchedule = upcomingSchedules.first(where: { $0.scheduled })
            if (nextSchedule == nil)
            {
                currState = .noSchedule
                counter = 0
            }
            else
            {
                currSession = nextSchedule!.type
                currState = .goingTomorrow
                counter = (nextSchedule!.time + 24 * 60 * 60) - nowTimeInterval
            }
        }
        else
        {
            var nextSession = currSession
            
            if (todayLastMealResponse != nil && todayLastMealResponse!.type.rawValue >= currSession.rawValue)
            {
                nextSession = whatNextSession(currSession, schedule: todaySchedule)!
            }
            
            let nextMeal = todaySchedules.first(where: { $0.type == nextSession })!
            currSession = nextMeal.type
            
            if (nowTimeInterval > nextMeal.time)
            {
                currState = .lateToday
                counter = nowTimeInterval - nextMeal.time
            }
            else
            {
                currState = .goingToday
                counter = nextMeal.time - nowTimeInterval
            }
        }
        
        // update today's respond
        views.enumerated().forEach({
            
            let data = todaySchedules[$0.offset]
            let todayResponse = todayMajorMealResponse.first(where: { $0.type == data.type })
            
            if (todayResponse != nil && todayResponse!.skip == false)
            {
                $0.element?.detail = todayResponse!.date.toString("hh:mm aa")
            }
            else if (todayLastMealResponse != nil && todayLastMealResponse!.type.rawValue > data.type.rawValue)
            {
                $0.element?.detail = "Not Scheduled"
            }
            else if (todayResponse == nil && data.scheduled)
            {
                $0.element?.detail = "Waiting"
            }
            else if (todayResponse != nil && todayResponse!.skip)
            {
                $0.element?.detail = "Skipped"
            }
            // this should be last in conditional, if user already responded and then the schedule is set to disable
            // it should show the "respond" (time / skipped) instead of "not scheduled"
            else if (todayResponse == nil && data.scheduled == false)
            {
                $0.element?.detail = "Not Scheduled"
            }
            
        })
        
        timerHourLabel.text = String(format: "%02d", Int(counter) / 3600)
        timerMinuteLabel.text = String(format: "%02d", Int(counter) % 3600 / 60)
        timerSeperatorLabel.isHidden = !timerSeperatorLabel.isHidden
        
        updateViewOnSession(newSession: currSession, newState: currState)
    }
    
}
