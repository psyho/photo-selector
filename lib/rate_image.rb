require 'faraday'
require 'base64'
require 'json'
require 'dotenv/load'

API_KEY = ENV.fetch("OPENAI_API_KEY")
PROMPT = <<~EOF
Rate this image on a scale of 0 to 100 for suitability in a photo album and describe its contents in a single sentence.

Rating should be based on color, composition, focus, lighting and emotional impact of the scene (memorable moments and places should score higher).
If an image is poorly composed, blurry, or has distracting elements, it should score lower.

Each reason should be rated on a scale of 0 to 100, with 0 being bad and 100 being amazing.
The overall rating should be an average of the five reasons.

Return the rating and description in the JSON format as follows:

```json
{ "description": "", "rating": 0, "reasons": { "color": 0, "composition": 0, "focus": 0, "lighting": 0, "emotional impact": 0 } }
```

Respond with ONLY JSON, and nothing else.
EOF

def encode_image(image_path)
  Base64.strict_encode64(File.binread(image_path))
end

def rate_image(image_path)
  base64_image = encode_image(image_path)

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{API_KEY}"
  }

  payload = {
    model: "gpt-4-vision-preview",
    messages: [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: PROMPT,
          },
          {
            type: "image_url",
            image_url: {
              url: "data:image/jpeg;base64,#{base64_image}"
            }
          }
        ]
      }
    ],
    max_tokens: 300
  }

  response = Faraday.post("https://api.openai.com/v1/chat/completions", payload.to_json, headers)

  if response.status == 200
    json_response = JSON.parse(response.body)
    content = json_response["choices"][0]["message"]["content"]
    clean_content = content.gsub(/^```.*$/, "")
    rating = JSON.parse(clean_content)
    rating["calculated_rating"] = (1.0 * rating["reasons"].values.sum / 5.0).round
    rating
  else
    fail "Error: #{response.status} #{response.body}"
  end
end
