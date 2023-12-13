require_relative 'openai'

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

def rate_image(image_path)
  content = execute_prompt(PROMPT, image_path)
  rating = parse_markdown_json(content)
  rating["calculated_rating"] = (1.0 * rating["reasons"].values.sum / 5.0).round
  rating
end
