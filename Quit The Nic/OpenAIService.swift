import Foundation

class OpenAIService {
    private let apiKey = "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"  // Replace with your actual OpenAI API key
    
    func fetchQuitPlan(
        nicotineType: String,
        productType: String,
        brand: String,
        strength: String,
        dailyIntake: String,
        costRange: String,
        quitTimeline: String,
        completion: @escaping (String) -> Void
    ) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Updated prompt with dosage and timeline consistency
        let prompt = """
        You are a quit coach assistant. Please create a structured quit plan for a user based on these details:
        - Nicotine type: \(nicotineType)
        - Product type: \(productType)
        - Brand: \(brand)
        - Strength: \(strength)
        - Daily intake: \(dailyIntake)
        - Cost range: \(costRange)
        - Desired quit timeline: \(quitTimeline)

        The quit plan should follow these requirements:
        1. **Overall Timeline Data**:
           - Break down the timeline by weeks, reducing the daily nicotine usage progressively to zero.
           - Each week should specify a target daily intake, with the usage amount decreasing steadily each week.
           - The structure should start at the user's current daily intake level and reach zero at the end of the timeline.
           - For example: Week 1: 10 uses per day, Week 2: 8 uses per day, Week 3: 6 uses per day, Week 4: 4 uses per day, Final Week: 0 uses per day.

        2. **Daily Goals**:
           - Each day should provide:
             - "Target Intake" (e.g., "10 uses")
             - "Motivational Quote" (a supportive message)
             - Optional "Nicotine Strength" that should decrease only towards the end of the plan.

        3. **Format the response as JSON** with "Overall Timeline Data" and "Daily Goals" sections.
        """


        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",  // or "gpt-4" if you have access
            "messages": [
                ["role": "system", "content": "You are a helpful assistant who provides structured, step-by-step quit plans."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 3000  // Allow for a detailed plan
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data:", error ?? "Unknown error")
                completion("Failed to retrieve quit plan.")
                return
            }
            
            // Print the raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            // Attempt to decode the response
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
