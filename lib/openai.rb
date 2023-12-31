require 'faraday'
require 'base64'
require 'json'
require 'dotenv/load'

API_KEY = ENV.fetch("OPENAI_API_KEY")

def encode_image(image_path)
  Base64.strict_encode64(File.binread(image_path))
end

def execute_prompt(prompt, *images, detail: "high", tokens_per_image: 200, timeout: 120)
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
                url: "data:image/jpeg;base64,#{image.respond_to?(:encoded) ? image.encoded : encode_image(image)}",
                detail:,
              },
            }
          end
        ]
      }
    ],
    # temperature: 0.5,
    # response_format: { type: "json_object" },
    max_tokens: tokens_per_image * images.size
  }

  response = Faraday.post("https://api.openai.com/v1/chat/completions", payload.to_json, headers) do |req|
    req.options.timeout = timeout
    req.options.open_timeout = timeout
  end

  if response.status == 200
    json_response = JSON.parse(response.body)
    json_response["choices"][0]["message"]["content"]
  else
    fail "Error: #{response.status} #{response.body}"
  end
end

def parse_markdown_json(content)
  index_of_first_brace = content.index("{") || content.index("[")
  index_of_last_brace = content.rindex("}") || content.rindex("]")
  fail "Could not find JSON in response: #{content}" unless index_of_first_brace && index_of_last_brace
  clean_content = content[index_of_first_brace..index_of_last_brace]
  JSON.parse(clean_content)
end
