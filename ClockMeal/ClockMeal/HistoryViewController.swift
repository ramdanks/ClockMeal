//
//  HistoryViewController.swift
//  ClockMeal
//
//  Created by Ramadhan Kalih Sewu on 28/04/22.
//

import UIKit

class HistoryViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var issueDetailView: RichRowDetailView!
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var consistencyEvaluationLabel: UILabel!
    
    @IBOutlet weak var breakfastScoreLabel: UILabel!
    @IBOutlet weak var lunchScoreLabel: UILabel!
    @IBOutlet weak var dinnerScoreLabel: UILabel!
    
    @IBOutlet weak var breakfastScoreImageView: UIImageView!
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var dinnerImageView: UIImageView!
    
    @IBOutlet weak var recordsTitleLabel: UILabel!
    @IBOutlet weak var recordsView: UIView!
    
    @IBOutlet weak var prevDateButton: UIButton!
    @IBOutlet weak var nextDateButton: UIButton!
    
    private var datePicker = MyDatePicker()
    private var tableView: UITableView = UITableView()
    private var dateRecords: [Response] = []
    
    private var recordsViewBottomConstraint: NSLayoutConstraint!
    private var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private var responses: [Response]!
    
    // default date set to today
    private var selectedDate: Date = Date()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        responses = Settings.responses
        
        tableView.isScrollEnabled = false
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "MealRecordCell", bundle: nil), forCellReuseIdentifier: "mealRecordCell")
    
        scrollView.addSubview(tableView)
        
        // set constraint on table view
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24).isActive = true
        tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24).isActive = true
        tableView.topAnchor.constraint(equalTo: recordsTitleLabel.bottomAnchor, constant: 8).isActive = true
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32)
        recordsViewBottomConstraint = recordsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32)
        
        loadDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        datePicker.dPicker.maximumDate = Date()
        responses = Settings.responses
        updateViewToDate(selectedDate)
    }
    
    private func updateViewToDate(_ date: Date)
    {
        dateButton.setTitle(date.toString("dd MMMM yyyy"), for: .normal)
        prevDateButton.isEnabled = responses.isEmpty ? false : !Calendar.current.isDate(date, inSameDayAs: responses.first!.date)
        nextDateButton.isEnabled = responses.isEmpty ? false : !Calendar.current.isDateInToday(date)
        datePicker.dPicker.date  = date

        dateRecords = responses.filter({ !$0.skip && Calendar.current.isDate(date, inSameDayAs: $0.date) })
        
        tableView.reloadData()
        
        
        if (dateRecords.isEmpty)
        {
            tableView.isHidden = true
            recordsView.isHidden = false
            recordsViewBottomConstraint.isActive = true
            tableViewBottomConstraint.isActive = false
        }
        else
        {
            recordsView.isHidden = true
            tableView.isHidden = false
            recordsViewBottomConstraint.isActive = false
            tableViewBottomConstraint.isActive = true
            
            // set constraint on table view
            if (tableViewHeightConstraint != nil)
            {
                tableViewHeightConstraint?.isActive = false
            }
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height)
            tableViewHeightConstraint?.isActive = true

            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
        }
    }
    
    @IBAction func onNextDateButton(_ sender: UIButton)
    {
        selectedDate = Calendar.current.date(byAdding: .day, value: +1, to: selectedDate)!
        updateViewToDate(selectedDate)
    }
    
    @IBAction func onPrevDateButton(_ sender: UIButton)
    {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
        updateViewToDate(selectedDate)
    }
    
    @IBAction func onDateButton(_ sender: UIButton)
    {
        displayDatePicker(true)
    }
    
    private func loadDatePicker()
    {
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // custom picker view should cover the whole view
            datePicker.topAnchor.constraint(equalTo: g.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: g.bottomAnchor),
        ])
        
        datePicker.isHidden = true
        datePicker.dPicker.datePickerMode = .date
        
        datePicker.dPicker.minimumDate = responses.isEmpty ? selectedDate : responses.first?.date
                
        datePicker.dismissClosure = { [self] in
            displayDatePicker(false)
            selectedDate = datePicker.dPicker.date
            updateViewToDate(selectedDate)
        }
    }
    
    func displayDatePicker(_ display: Bool)
    {
        UIView.transition(
            with: self.view,
            duration: 0.25,
            options: [.transitionCrossDissolve],
            animations: { self.datePicker.isHidden = !display },
            completion: nil
        )
    }
    
}

extension HistoryViewController: UITableViewDelegate
{
    
}

extension HistoryViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dateRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealRecordCell", for: indexPath) as! MealRecordCell
        let data = dateRecords[indexPath.row]
        
        var imageName: String!
        if (data.type == .breakfast) { imageName = "b.square.fill"  }
        if (data.type == .lunch)     { imageName = "l.square.fill"  }
        if (data.type == .dinner)    { imageName = "d.square.fill"  }
        if (data.type == .snack)     { imageName = "s.circle.fill"  }
        
        cell.titleLabel.text = "\(data.type)".capitalized
        cell.detailLabel.text = data.date.toString("hh:mm aa")
        cell.leftImageView.image = UIImage(systemName: imageName)
        
        return cell
    }
}
