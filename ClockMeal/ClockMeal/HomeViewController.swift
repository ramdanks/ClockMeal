import UIKit

class HomeViewController: UIViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
    }
    
    @IBAction func onSkipMealButton(_ sender: UIButton)
    {
        
    }
    
}
