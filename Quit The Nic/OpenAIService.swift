import Foundation

class OpenAIService {
    private let apiKey = API KEY HERE  // Replace with your actual OpenAI API key
   
        
    func fetchQuitPlan(
        nicotineType: String,
        productType: String,
        brand: String,
        strength: String,
        dailyIntake: String,
        specificDailyIntake: String,
        costRange: String,
        quitTimeline: String,
        completion: @escaping (String) -> Void
    ) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Define the duration in days based on the timeline
        let durationInDays: Int
        switch quitTimeline.lowercased() {
        case "1 month":
            durationInDays = 28
        case "2 months":
            durationInDays = 56
        case "3 months":
            durationInDays = 84
        case "6 months":
            durationInDays = 168
        case "1 year":
            durationInDays = 336
        default:
            durationInDays = 28 // Default to 1 month if unspecified
        }

        // Enhanced prompt to handle multiple timelines and specific requirements
        let prompt = """
        You are an expert in creating structured, step-by-step quit plans tailored for nicotine users. Please generate a detailed quit plan in JSON format based on the following user details. 

        ### Requirements:
        1. **Duration**: The plan should cover exactly \(durationInDays) days, listing each day sequentially from Day 1 to Day \(durationInDays) with no skipped days.
        2. **Reduction Guidelines**:
           - **Dosage Reduction**: Gradually reduce the dosage only when a lower strength is available for the specified product and brand. For example, if starting at 8mg and lower strengths exist (e.g., 4mg, 2mg), step down to those strengths as part of the reduction.
           - **Intake Reduction**: Reduce the daily intake gradually, without setting any day to 0 intake until the final day.
           - **No Skipped Days**: Each day must be explicitly listed in the JSON, even if the intake remains the same across several days. 
        3. **Structure**:
           - **weekly_overview**: Provide an overview of each week, reducing the daily intake gradually, with examples like:
             - "Week 1": "15 units at 8mg"
             - "Week 2": "12 units at 8mg"
             - Continue reducing intake until the final week, which should reach "0 units."
           - **daily_goals**: List each day’s goal with:
             - `target_intake`: The number of units and dosage for the day, e.g., "12 units at 4mg."
             - `motivational_quote`: A unique motivational quote for that day.
           - **JSON Structure**:
             ```json
             {
               "quit_plan": {
                 "duration": "\(durationInDays) days",
                 "user_details": {
                   "nicotine_type": "\(nicotineType)",
                   "product_type": "\(productType)",
                   "brand": "\(brand)",
                   "starting_strength": "\(strength)",
                   "daily_intake": "\(specificDailyIntake) units per day",
                   "cost_range": "\(costRange)",
                   "timeline": "\(quitTimeline)"
                 },
                 "weekly_overview": {
                   "Week 1": "15 units at 8mg",
                   "Week 2": "12 units at 8mg",
                   ...
                   "Final Week": "0 units"
                 },
                 "daily_goals": [
                   { "Day 1": { "target_intake": "15 units at 8mg", "motivational_quote": "Stay strong!" } },
                   { "Day 2": { "target_intake": "15 units at 8mg", "motivational_quote": "Keep going, you're doing great!" } },
                   ...
                   { "Day \(durationInDays)": { "target_intake": "0 units at 0mg", "motivational_quote": "Congratulations! You've reached your goal!" } }
                 ]
               }
             }
             ```

        ### User Information:
           - **Nicotine Type**: \(nicotineType)
           - **Product Type**: \(productType)
           - **Brand**: \(brand)
           - **Starting Strength**: \(strength)
           - **Daily Intake**: \(specificDailyIntake)
           - **Cost Range**: \(costRange)
           - **Timeline**: \(quitTimeline)

        ### Important Notes:
           - **Every Day Listed**: The `daily_goals` array must list every day sequentially from Day 1 to Day \(durationInDays) with no missing days. If a reduction in units does not occur, list the same target intake across consecutive days.
           - **Ending at Zero**: Ensure that the final day (Day \(durationInDays)) is the only day with a target intake of "0 units."
           - **Dosage Availability**: Use only the available dosages specific to this product and brand.
           - **Return the result in JSON format** without any extra commentary or explanation.
        """



        let body: [String: Any] = [
            "model": "gpt-4-0613",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant who provides structured, step-by-step quit plans."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 4000
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data:", error ?? "Unknown error")
                completion("Failed to retrieve quit plan.")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }

            do {
                let responseObject = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let outputText = responseObject.choices.first?.message.content ?? ""
                completion(outputText.trimmingCharacters(in: .whitespacesAndNewlines))
            } catch {
                print("Failed to parse the response:", error)
                completion("Failed to parse the quit plan response.")
            }
        }.resume()
    
        }
        
        struct OpenAIResponse: Codable {
            let choices: [Choice]
        }
        
        struct Choice: Codable {
            let message: Message
        }
        
        struct Message: Codable {
            let content: String
        }
    }
