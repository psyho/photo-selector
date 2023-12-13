require_relative 'openai'

PROMPT = <<~EOF
Compare these two images and pick the one that is better suited for a family photo album.

Consider the following:
- color
- composition
- focus
- lighting
- emotional impact

Duplicates are not just photos of the same people in the same location and pose, 
but any two photos that are taken in the same location and lighting conditions.
In that case, pick the one that has more people in it, or if they have the same number of people, 
use their facial expressions and poses to decide which one is better.

Output should be one of:
FIRST - first image is better
SECOND - second image is better
DUPLICATE_FIRST - both images feature similar content, but the first image is (slightly) better
DUPLICATE_SECOND - both images feature similar content, but the second image is (slightly) better

Explain your reasoning in a single sentence. Then output one of the above options.

Output should be in the following JSON format:

```json
{ "explanation": "", "choice: "" }
```

With explanation being the reason for your choice, and choice being one of the above options.
Respond with ONLY JSON, and nothing else.
EOF

module CompareImages
  InvalidChoice = Class.new(StandardError)

  FIRST = "FIRST"
  SECOND = "SECOND"
  DUPLICATE_FIRST = "DUPLICATE_FIRST"
  DUPLICATE_SECOND = "DUPLICATE_SECOND"

  ALL = [FIRST, SECOND, DUPLICATE_FIRST, DUPLICATE_SECOND].freeze
end

def compare_images(left_image_path, right_image_path)
  content = execute_prompt(PROMPT, left_image_path, right_image_path)
  result = parse_markdown_json(content)
  choice = result["choice"]
  fail CompareImages::InvalidChoice, choice.inspect unless CompareImages::ALL.include?(choice)
  choice
end
