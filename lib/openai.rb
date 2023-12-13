require 'faraday'
require 'base64'
require 'json'
require 'dotenv/load'

API_KEY = ENV.fetch("OPENAI_API_KEY")

def encode_image(image_path)
  Base64.strict_encode64(File.binread(image_path))
end

def execute_prompt(prompt, *images)
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
            text: prompt,
          },
          *images.map do |image|
            {
              type: "image_url",
              image_url: {
                url: "data:image/jpeg;base64,#{encode_image(image)}",
                detail: "high",
              },
            }
          end
        ]
      }
    ],
    max_tokens: 600
  }

  response = Faraday.post("https://api.openai.com/v1/chat/completions", payload.to_json, headers)

  if response.status == 200
    json_response = JSON.parse(response.body)
    json_response["choices"][0]["message"]["content"]
  else
    fail "Error: #{response.status} #{response.body}"
  end
end

def parse_markdown_json(content)
  clean_content = content.gsub(/^```.*$/, "")
  JSON.parse(clean_content)
end
