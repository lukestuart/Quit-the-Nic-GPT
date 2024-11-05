import UIKit

// MARK: - Data Models

struct AppState {
    var step: Int = 0
    var nicotineType: String = ""
    var productType: String = ""
    var brand: String = ""
    var strength: String = ""
    var dailyIntake: String = ""
    var specificDailyIntake: String = ""
    var costRange: String = ""
    var specificCost: String = ""
    var quitTimeline: String = ""
    var responses: [String: String] = [:]
    var quitPlan: [String] = []
    var currentDay: Int = 1
    var dailyUsage: Int = 0
    var dailyLimit: Int = 0
    var overallTimeline: [Int] = [] // Weekly usage goals parsed from AI response
    var dailyGoals: [(target: Int, quote: String, strength: String)] = [] // Daily goals parsed from AI response with strength
}

struct Question {
    let text: String
    let options: [String]
}

// MARK: - Questions Dictionary

let questions: [String: Any] = [
    "nicotineType": Question(text: "What form of nicotine do you consume?", options: ["Vape", "Cigarettes", "Pouches", "Gum", "Patches"]),
    "productTypes": [
        "Vape": Question(text: "What kind of vape do you use?", options: ["Disposable Pod System", "Refillable Pod System", "Disposable", "Box Mod"]),
        "Cigarettes": Question(text: "What kind of cigarettes do you smoke?", options: ["Regulars", "Lights", "Menthols", "Ultra-Lights"]),
        "Pouches": Question(text: "What type of nicotine pouch do you use?", options: ["Tobacco-Free", "Tobacco-Containing"]),
        "Gum": Question(text: "What type of nicotine gum do you use?", options: ["Regular", "Sugar-Free"]),
        "Patches": Question(text: "What type of nicotine patch do you use?", options: ["Step 1 (High Dose)", "Step 2 (Medium Dose)", "Step 3 (Low Dose)"])
    ] as [String: Question],
    "brands": [
        "Vape": [
            "Disposable": Question(text: "Which disposable brand do you use?", options: ["Puff Bar", "Hyde", "Fume", "Bang", "Air Bar", "Other"]),
            "Disposable Pod System": Question(text: "Which disposable pod system do you use?", options: ["Juul", "Vuse", "Blu", "Stig", "Pop", "Other"]),
            "Refillable Pod System": Question(text: "Which refillable pod system do you use?", options: ["SMOK", "Voopoo", "Uwell", "Suorin", "Lost Vape", "Other"]),
            "Box Mod": Question(text: "Which box mod brand do you use?", options: ["SMOK", "GeekVape", "Voopoo", "Vaporesso", "Wismec", "Other"])
        ] as [String: Question],
        "Cigarettes": [
            "Regulars": Question(text: "Which regular cigarette brand do you use?", options: ["Marlboro", "Camel", "Winston", "Lucky Strike", "American Spirit", "Other"]),
            "Lights": Question(text: "Which light cigarette brand do you use?", options: ["Marlboro Lights", "Camel Lights", "Newport Lights", "Parliament Lights", "Virginia Slims", "Other"]),
            "Menthols": Question(text: "Which menthol brand do you use?", options: ["Newport", "Marlboro Menthol", "Camel Menthol", "Kool", "Salem", "Other"]),
            "Ultra-Lights": Question(text: "Which ultra-light cigarette brand do you use?", options: ["Marlboro Ultra Lights", "Camel Ultra Lights", "Pall Mall Ultra Lights", "Parliament Ultra Lights", "Virginia Slims Ultra Lights", "Other"])
        ] as [String: Question],
        "Pouches": [
            "Tobacco-Free": Question(text: "Which tobacco-free pouch brand do you use?", options: ["Zyn", "On!", "Velo", "Rogue", "Skruf", "Other"]),
            "Tobacco-Containing": Question(text: "Which tobacco-containing pouch brand do you use?", options: ["Grizzly", "Skoal", "Copenhagen", "Kodiak", "Red Seal", "Other"])
        ] as [String: Question],
        "Gum": [
            "Regular": Question(text: "Which regular nicotine gum brand do you use?", options: ["Nicorette", "Rite Aid", "CVS", "Equate", "Habitrol", "Other"]),
            "Sugar-Free": Question(text: "Which sugar-free nicotine gum brand do you use?", options: ["Nicorette", "Habitrol", "Nicoderm", "CVS", "Rite Aid", "Other"])
        ] as [String: Question],
        "Patches": [
            "Step 1 (High Dose)": Question(text: "Which high-dose patch brand do you use?", options: ["NicoDerm CQ", "Habitrol", "Rite Aid", "CVS", "Walgreens", "Other"]),
            "Step 2 (Medium Dose)": Question(text: "Which medium-dose patch brand do you use?", options: ["NicoDerm CQ", "Habitrol", "Nicorette", "CVS", "Rite Aid", "Other"]),
            "Step 3 (Low Dose)": Question(text: "Which low-dose patch brand do you use?", options: ["NicoDerm CQ", "Habitrol", "Rite Aid", "CVS", "Nicorette", "Other"])
        ] as [String: Question]
    ] as [String: [String: Question]],
    "strengths": [
        "On!": ["2mg", "4mg", "8mg"],
        "Juul": ["3% Pods", "5% Pods"],
        "Zyn": ["3mg", "6mg"],
        "Marlboro": ["Full Flavor", "Light", "Menthol"],
        "Nicorette": ["2mg", "4mg"],
        "NicoDerm CQ": ["Step 1 (High Dose)", "Step 2 (Medium Dose)", "Step 3 (Low Dose)"]
    ] as [String: [String]],
    "dailyIntake": Question(text: "How many times per day do you use your product?", options: ["1-5", "6-10", "7-15", "16-20", "20+"]),
    "costRange": Question(text: "How much does a unit cost in your state?", options: ["$1-$5", "$6-$10", "$11-$15", "$16-$20", "More than $20"]),
    "quitTimeline": Question(text: "When would you like to quit?", options: ["1 month", "2 months", "3 months", "6 months", "1 year"])
]

// MARK: - Main Controller

class QuitNicotineViewController: UIViewController {
    var appState = AppState()
    var questionLabel: UILabel!
    var optionsStackView: UIStackView!
    var dailyLabel: UILabel!
    var overviewButton: UIButton!
    var dailyGoalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        startApp()
    }

    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.16, blue: 0.42, alpha: 1).cgColor,
            UIColor(red: 0.7, green: 0.12, blue: 0.12, alpha: 1).cgColor,
            UIColor(red: 0.99, green: 0.73, blue: 0.18, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupUI() {
        questionLabel = UILabel()
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        questionLabel.textColor = .white
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)

        optionsStackView = UIStackView()
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 10
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsStackView)

        dailyLabel = UILabel()
        dailyLabel.textAlignment = .center
        dailyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dailyLabel.textColor = .white
        dailyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyLabel)
        
        // Add the Overview button
        overviewButton = UIButton(type: .system)
        overviewButton.setTitle("Overview", for: .normal)
        overviewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        overviewButton.tintColor = .systemBlue
        overviewButton.addTarget(self, action: #selector(showOverview), for: .touchUpInside)
        overviewButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overviewButton)
        
        // Add the Daily Goal button
        dailyGoalButton = UIButton(type: .system)
        dailyGoalButton.setTitle("Daily Goal", for: .normal)
        dailyGoalButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        dailyGoalButton.tintColor = .systemBlue
        dailyGoalButton.addTarget(self, action: #selector(showDailyGoal), for: .touchUpInside)
        dailyGoalButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyGoalButton)

        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dailyLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 40),
            dailyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            overviewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            overviewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            dailyGoalButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            dailyGoalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Start App

    func startApp() {
        appState.step = 1
        renderQuestion()
    }

    func renderQuestion() {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous options
        
        switch appState.step {
        case 1:
            renderOptions(question: questions["nicotineType"] as? Question)
        case 2:
            if let productTypeQuestion = (questions["productTypes"] as? [String: Question])?[appState.nicotineType] {
                renderOptions(question: productTypeQuestion)
            } else {
                skipToNextStep()
            }
        case 3:
            if let brandQuestion = (questions["brands"] as? [String: [String: Question]])?[appState.nicotineType]?[appState.productType] {
                renderOptions(question: brandQuestion)
            } else {
                skipToNextStep()
            }
        case 4:
            if appState.nicotineType != "Cigarettes",
               let strengthOptions = (questions["strengths"] as? [String: [String]])?[appState.brand] {
                renderOptions(question: Question(text: "What level of nicotine do you use?", options: strengthOptions))
            } else {
                skipToNextStep()
            }
        case 5:
            renderOptions(question: questions["dailyIntake"] as? Question)
        case 6:
            renderSpecificDailyIntakeOptions(dailyIntakeRange: appState.dailyIntake)
        case 7:
            renderOptions(question: questions["costRange"] as? Question)
        case 8:
            renderSpecificCostOptions(costRange: appState.costRange)
        case 9:
            renderOptions(question: questions["quitTimeline"] as? Question)
        default:
            fetchQuitPlanFromGPT() // End of questions
        }
    }

    func skipToNextStep() {
        appState.step += 1
        renderQuestion()
    }

    func renderSpecificDailyIntakeOptions(dailyIntakeRange: String) {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous options
        
        questionLabel.text = "Please specify your daily intake more precisely."

        let options: [String] = {
            switch dailyIntakeRange {
            case "1-5": return ["1", "2", "3", "4", "5"]
            case "6-10": return ["6", "7", "8", "9", "10"]
            case "7-15": return ["7", "8", "9", "10", "11", "12", "13", "14", "15"]
            case "16-20": return ["16", "17", "18", "19", "20"]
            case "20+": return ["21", "22", "23", "24", "25+"]
            default: return []
            }
        }()

        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
    }

    func renderSpecificCostOptions(costRange: String) {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous options

        questionLabel.text = "Please specify the exact cost."

        let options: [String] = {
            switch costRange {
            case "$1-$5": return ["$1", "$2", "$3", "$4", "$5"]
            case "$6-$10": return ["$6", "$7", "$8", "$9", "$10"]
            case "$11-$15": return ["$11", "$12", "$13", "$14", "$15"]
            case "$16-$20": return ["$16", "$17", "$18", "$19", "$20"]
            case "More than $20": return ["$21-$25", "$26-$30", "$31-$35", "$36+"]
            default: return []
            }
        }()

        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
    }

    func renderOptions(question: Question?) {
        guard let question = question else { return }
        questionLabel.text = question.text

        for option in question.options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
    }

    @objc func optionSelected(_ sender: UIButton) {
        guard let response = sender.titleLabel?.text else { return }
        handleResponse(response: response)
    }
    
    func handleResponse(response: String) {
        switch appState.step {
        case 1: appState.nicotineType = response
        case 2: appState.productType = response
        case 3: appState.brand = response
        case 4: appState.strength = response
        case 5: appState.dailyIntake = response
        case 6: appState.specificDailyIntake = response
        case 7: appState.costRange = response
        case 8: appState.specificCost = response
        case 9: appState.quitTimeline = response
        default: break
        }

        appState.responses["Q\(appState.step)"] = response
        appState.step += 1
        renderQuestion()
    }

    // MARK: - Daily Progress and Overview Functions

    @objc func showOverview() {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous UI elements
        questionLabel.text = "Your Quit Plan Overview"

        // Show Overall Timeline
        if !appState.overallTimeline.isEmpty {
            let timelineLabel = UILabel()
            timelineLabel.text = "Overall Timeline"
            timelineLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            timelineLabel.textColor = .white
            timelineLabel.textAlignment = .center
            optionsStackView.addArrangedSubview(timelineLabel)
            
            for (index, usage) in appState.overallTimeline.enumerated() {
                let weekLabel = UILabel()
                weekLabel.text = "Week \(index + 1): \(usage) uses per day"
                weekLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                weekLabel.textAlignment = .center
                weekLabel.textColor = .white
                optionsStackView.addArrangedSubview(weekLabel)
            }
            
        } else {
            let noDataLabel = UILabel()
            noDataLabel.text = "No overall timeline data available."
            noDataLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .white
            optionsStackView.addArrangedSubview(noDataLabel)
        }

        // Show Daily Goals
        if !appState.dailyGoals.isEmpty {
            let goalsLabel = UILabel()
            goalsLabel.text = "Daily Goals"
            goalsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            goalsLabel.textColor = .white
            goalsLabel.textAlignment = .center
            optionsStackView.addArrangedSubview(goalsLabel)

            for (index, goal) in appState.dailyGoals.enumerated() {
                let dayLabel = UILabel()
                dayLabel.text = "Day \(index + 1): \(goal.target) uses - \(goal.quote) at \(goal.strength)"
                dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                dayLabel.textAlignment = .center
                dayLabel.textColor = .white
                optionsStackView.addArrangedSubview(dayLabel)
            }
        } else {
            let noGoalsLabel = UILabel()
            noGoalsLabel.text = "No daily goals available."
            noGoalsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            noGoalsLabel.textAlignment = .center
            noGoalsLabel.textColor = .white
            optionsStackView.addArrangedSubview(noGoalsLabel)
        }
    }

    @objc func showDailyGoal() {
        let dailyGoalVC = DailyGoalViewController()
        if appState.currentDay - 1 < appState.dailyGoals.count {
            let todayGoal = appState.dailyGoals[appState.currentDay - 1]
            dailyGoalVC.configure(with: (todayGoal.target, todayGoal.quote, todayGoal.strength))
        } else {
            print("No daily goal found for day \(appState.currentDay)")
        }
        navigationController?.pushViewController(dailyGoalVC, animated: true)
    }


    // MARK: - API Request and Quit Plan Fetching

    func fetchQuitPlanFromGPT() {
        let openAIService = OpenAIService()
        openAIService.fetchQuitPlan(
            nicotineType: appState.nicotineType,
            productType: appState.productType,
            brand: appState.brand,
            strength: appState.strength,
            dailyIntake: appState.dailyIntake,
            costRange: appState.costRange,
            quitTimeline: appState.quitTimeline
        ) { [weak self] quitPlan in
            DispatchQueue.main.async {
                print("Received Quit Plan:", quitPlan)
                self?.processQuitPlanResponse(quitPlan)
            }
        }
    }

    func processQuitPlanResponse(_ quitPlan: String) {
        guard let data = quitPlan.data(using: .utf8) else {
            print("Failed to convert quit plan to Data")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                appState.dailyGoals.removeAll()
                appState.overallTimeline.removeAll()
                
                if let overallTimelineData = json["Overall Timeline Data"] as? [String: String] {
                    for week in overallTimelineData.keys.sorted() {
                        if let usageValue = overallTimelineData[week]?.components(separatedBy: " ").first, let usageInt = Int(usageValue) {
                            appState.overallTimeline.append(usageInt)
                        }
                    }
                }
                
                if let dailyGoalsDict = json["Daily Goals"] as? [String: [String: Any]] {
                    for day in dailyGoalsDict.keys.sorted() {
                        if let goalData = dailyGoalsDict[day],
                           let target = goalData["Target Intake"] as? String,
                           let intakeValue = Int(target.components(separatedBy: " ").first ?? ""),
                           let motivationalQuote = goalData["Motivational Quote"] as? String {
                            let strength = goalData["Nicotine Strength"] as? String ?? "Not specified"
                            appState.dailyGoals.append((target: intakeValue, quote: motivationalQuote, strength: strength))
                        }
                    }
                }
            } else {
                print("Failed to parse quit plan response.")
            }
        } catch {
            print("Error parsing quit plan response: \(error)")
        }
    }


    
    // MARK: - Daily Progress Functions
        
    @objc func showDailyProgress() {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard appState.currentDay <= appState.dailyGoals.count else {
            displayCompletionMessage()
            return
        }
        
        let todayGoal = appState.dailyGoals[appState.currentDay - 1]
        appState.dailyLimit = todayGoal.target
        
        questionLabel.text = "Today's Goal: \(todayGoal.target) uses at \(todayGoal.strength) strength"
        
        let usageLabel = UILabel()
        usageLabel.text = "\(appState.dailyUsage) / \(appState.dailyLimit)"
        usageLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        usageLabel.textAlignment = .center
        usageLabel.textColor = .systemBlue
        optionsStackView.addArrangedSubview(usageLabel)
        
        let incrementButton = UIButton(type: .system)
        incrementButton.setTitle("Use Product", for: .normal)
        incrementButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        incrementButton.tintColor = .white
        incrementButton.backgroundColor = .systemBlue
        incrementButton.layer.cornerRadius = 10
        incrementButton.addTarget(self, action: #selector(incrementUsage), for: .touchUpInside)
        optionsStackView.addArrangedSubview(incrementButton)
        
        let quoteLabel = UILabel()
        quoteLabel.text = todayGoal.quote
        quoteLabel.font = UIFont.italicSystemFont(ofSize: 16)
        quoteLabel.textAlignment = .center
        quoteLabel.textColor = .darkGray
        quoteLabel.numberOfLines = 0
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quoteLabel)
        
        NSLayoutConstraint.activate([
            quoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            quoteLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func incrementUsage() {
        guard appState.currentDay <= appState.dailyGoals.count else { return }
        appState.dailyUsage += 1
        
        if let usageLabel = optionsStackView.arrangedSubviews.first(where: { $0 is UILabel }) as? UILabel {
            usageLabel.text = "\(appState.dailyUsage) / \(appState.dailyLimit)"
        }
        
        if appState.dailyUsage > appState.dailyLimit {
            let alert = UIAlertController(
                title: "Warning",
                message: "You've exceeded your daily limit. Try to stick to the plan!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc func nextDay() {
        if appState.currentDay < appState.dailyGoals.count {
            appState.currentDay += 1
            appState.dailyUsage = 0
            showDailyProgress()
        } else {
            displayCompletionMessage()
        }
    }
    
    func displayCompletionMessage() {
        let alert = UIAlertController(
            title: "Congratulations!",
            message: "You've completed the quit plan! Keep up the great work staying nicotine-free!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
