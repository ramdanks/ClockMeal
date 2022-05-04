import UIKit

class ScheduleViewController: UIViewController
{
    /// 0 -> Today | 1 -> Upcoming Day
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var breakfastCard: ScheduleCardControl!
    @IBOutlet weak var lunchCard: ScheduleCardControl!
    @IBOutlet weak var dinnerCard: ScheduleCardControl!
    
    private var selectedCard: ScheduleCardControl!
    var todayMajorMealResponse: [Response] = []
    
    private var mealCollection: MealCollection! { didSet {
        mealCollection.breakfastData.issues = MealRules.issues(collection: mealCollection, forType: .breakfast)
        mealCollection.lunchData.issues     = MealRules.issues(collection: mealCollection, forType: .lunch)
        mealCollection.dinnerData.issues    = MealRules.issues(collection: mealCollection, forType: .dinner)
        breakfastCard.data                  = mealCollection.breakfastData
        dinnerCard.data                     = mealCollection.dinnerData
        lunchCard.data                      = mealCollection.lunchData
    }}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mealCollection = Settings.mealDataCollection
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let homeVC = self.tabBarController?.viewControllers![0] as! HomeViewController
        todayMajorMealResponse = homeVC.todayMajorMealResponse
    }
    
    @IBAction func onScheduleCardButton(_ sender: ScheduleCardControl)
    {
        // check if session is already passed for today schedule
        if (segmentedControl.selectedSegmentIndex == 0)
        {
            let todayLastMealResponse = todayMajorMealResponse.max(by: { $0.type.rawValue < $1.type.rawValue })?.type.rawValue ?? -1
            if (todayLastMealResponse >= sender.data.type.rawValue)
            {
                let alert = UIAlertController(
                    title: "Edit Schedeule",
                    message: "You cannot edit today's schedule of this meal because you already passed this session",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                present(alert, animated: true)
                return
            }
        }
        selectedCard = sender
        performSegue(withIdentifier: SegueIdentifier.mealDetail, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == SegueIdentifier.mealDetail)
        {
            guard let destinationVC = segue.destination as? MealDetailViewController
            else { return }
            destinationVC.collection = mealCollection
            destinationVC.type = selectedCard.data.type
            destinationVC.imageShowcase = selectedCard.image
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue)
    {
        if (segue.identifier == SegueIdentifier.mealDetailUnwind)
        {
            let vc = segue.source as! MealDetailViewController
            mealCollection = vc.collection
            setSettingCollection(mealCollection)
        }
    }
    
    @IBAction func onSegmentedChange(_ sender: UISegmentedControl)
    {
        mealCollection = sender.selectedSegmentIndex == 0 ? Settings.mealDataCollection : Settings.upcomingSchedule
    }
    
    @IBAction func onRepeatLeastIssueButton(_ sender: Any) {
    }
    
    @IBAction func onRepeatYesterdayButton(_ sender: Any) {
    }
    
    @IBAction func onRevertDefaultButton(_ sender: Any)
    {
        let alert = UIAlertController(
            title: "Revert Default",
            message: "This will reset the currently running schedule. Are you sure want to continue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Revert My Schedule", style: .default, handler: { [self] action in
            mealCollection = Settings.mealDataCollectionDefault
            setSettingCollection(mealCollection)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func setSettingCollection(_ collection: MealCollection)
    {
        if (segmentedControl.selectedSegmentIndex == 0) { Settings.mealDataCollection = collection }
        if (segmentedControl.selectedSegmentIndex == 1) { Settings.upcomingSchedule = collection }
    }
}

extension ScheduleViewController
{
    struct SegueIdentifier
    {
        static let mealDetail = "mealDetailSegue"
        static let mealDetailUnwind = "unwindSegue"
    }
}
