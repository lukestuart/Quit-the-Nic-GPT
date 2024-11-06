import UIKit

class DailyGoalViewController: UIViewController {
    var appState: AppState! // Reference to appState from QuitNicotineViewController
    var targetUsage: Int = 0
    var motivationalQuote: String = ""
    var nicotineStrength: String = ""
    var currentUsage: Int = 0
    var currentDay: Int = 1  // Track which day the user is on

    private var usageLabel = UILabel()
    private var targetLabel = UILabel() // Label for displaying today's goal
    private var strengthLabel = UILabel() // Label for displaying nicotine strength
    private var quoteLabel = UILabel()
    private let circularProgressView = CircularProgressView()
    private var incrementButton = UIButton() // Button to log usage

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Load current day and usage progress from UserDefaults
        currentDay = UserDefaults.standard.integer(forKey: "currentDay")
        if currentDay == 0 { currentDay = 1 } // Default to day 1 if no data saved
        currentUsage = UserDefaults.standard.integer(forKey: "currentUsage")

        print("Loaded currentDay: \(currentDay), currentUsage: \(currentUsage)")

        loadDailyGoal() // Load today's goal from appState
        updateUsageDisplay() // Update UI with current usage
    }

    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = UIColor.white

        // Circular Progress View
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularProgressView)

        // Target Label
        targetLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        targetLabel.textAlignment = .center
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetLabel)

        // Usage Label
        usageLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        usageLabel.textAlignment = .center
        usageLabel.textColor = .systemBlue
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usageLabel)

        // Strength Label
        strengthLabel.font = UIFont.systemFont(ofSize: 18)
        strengthLabel.textAlignment = .center
        strengthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(strengthLabel)

        // Quote Label (motivational text only)
        quoteLabel.font = UIFont.italicSystemFont(ofSize: 18)
        quoteLabel.numberOfLines = 0
        quoteLabel.textAlignment = .center
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quoteLabel)

        // Increment Button
        incrementButton.setTitle("Use Product", for: .normal)
        incrementButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        incrementButton.backgroundColor = .systemBlue
        incrementButton.setTitleColor(.white, for: .normal)
        incrementButton.layer.cornerRadius = 10
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.addTarget(self, action: #selector(incrementUsage), for: .touchUpInside)
        view.addSubview(incrementButton)

        // Layout Constraints
        NSLayoutConstraint.activate([
            circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            circularProgressView.widthAnchor.constraint(equalToConstant: 200),
            circularProgressView.heightAnchor.constraint(equalToConstant: 200),

            targetLabel.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 20),
            targetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            usageLabel.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 20),
            usageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            strengthLabel.topAnchor.constraint(equalTo: usageLabel.bottomAnchor, constant: 20),
            strengthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            quoteLabel.topAnchor.constraint(equalTo: strengthLabel.bottomAnchor, constant: 20),
            quoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            incrementButton.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 40),
            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            incrementButton.widthAnchor.constraint(equalToConstant: 200),
            incrementButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Load Daily Goal

    func loadDailyGoal() {
        print("Loading daily goal for day \(currentDay)")

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("AppDelegate not found.")
            return
        }

        let appState = appDelegate.appState
        print("Total daily goals in appState: \(appState.dailyGoals.count)")

        if currentDay - 1 >= 0 && currentDay - 1 < appState.dailyGoals.count {
            let todayGoal = appState.dailyGoals[currentDay - 1]
            configure(with: todayGoal)
        } else {
            print("No daily goal found for day \(currentDay)")
            targetLabel.text = "No daily goal found for day \(currentDay)"
            usageLabel.text = ""
            strengthLabel.text = ""
            quoteLabel.text = "Stay motivated!"
        }
    }

    func configure(with dailyGoal: (target: Int, quote: String, strength: String?)) {
        print("Configuring daily goal with target: \(dailyGoal.target), quote: \(dailyGoal.quote), strength: \(dailyGoal.strength ?? "N/A")")
        self.targetUsage = dailyGoal.target
        self.motivationalQuote = dailyGoal.quote
        self.nicotineStrength = dailyGoal.strength ?? "Not specified"
        updateUI()
    }

    func updateUI() {
        DispatchQueue.main.async {
            print("Updating UI on main thread with targetUsage: \(self.targetUsage), currentUsage: \(self.currentUsage), nicotineStrength: \(self.nicotineStrength), motivationalQuote: \(self.motivationalQuote)")
            self.usageLabel.text = "\(self.currentUsage) / \(self.targetUsage)"
            self.targetLabel.text = "Today's Goal: \(self.targetUsage) uses"
            self.strengthLabel.text = "Strength: \(self.nicotineStrength)"
            self.quoteLabel.text = self.motivationalQuote
            self.updateUsageDisplay()
        }
    }

    // MARK: - Usage Tracking

    @objc func incrementUsage() {
        if currentUsage < targetUsage {
            currentUsage += 1
            UserDefaults.standard.set(currentUsage, forKey: "currentUsage")
            updateUsageDisplay()

            if currentUsage == targetUsage {
                showCompletionAlert()
            }
        } else {
            let alert = UIAlertController(
                title: "Limit Exceeded",
                message: "You've reached the maximum uses for today. Great job!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func updateUsageDisplay() {
        // Update the progress label and circular progress bar based on current usage
        usageLabel.text = "\(currentUsage) / \(targetUsage)"
        let progress = targetUsage == 0 ? 0 : Float(currentUsage) / Float(targetUsage)
        circularProgressView.setProgress(to: progress)
    }

    // MARK: - Completion Alert

    func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Goal Reached!",
            message: "You've met your goal for today. Keep up the good work!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.advanceToNextDay()
        }))
        present(alert, animated: true)
    }

    // MARK: - Advance to Next Day

    func advanceToNextDay() {
        currentDay += 1
        currentUsage = 0 // Reset usage for the new day
        UserDefaults.standard.set(currentDay, forKey: "currentDay")
        UserDefaults.standard.set(currentUsage, forKey: "currentUsage")
        loadDailyGoal() // Load the next day’s goal
    }
}
