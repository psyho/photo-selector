# Filtering images using GPT-4-Vision

This repo contains some experiments with gpt-4-vision-preview that I used to filter down ~2000 images from my trip into a more manageable set of ~100 images for a photo album.

The "final" script that I used is in [bin/filter-in-batches](bin/filter-in-batches).
There's not much to it - just a prompt and a loop, nothing fancy.

A couple of things learned:
- The gpt-4-vision-preview model as of December 2023 has very stringent API limits, so any approach that passes only one or two pictures will not work.
- There's also not much room for running stuff in parallel, because of the per-minute limits.
- Maybe it's because of the image resizing, but it doesn't seem to detect out-of-focus photos very well.
- The duplicate detection is pretty good.
- gpt-4-vision-preview does not support JSON output, unfortunately.
- The model is super stupid sometimes, and will respond with things like "do it yourself", "I can't process multiple images at once", "I'm not allowed to work with personal photos", "I can't help you with that". Given enough retries, it turns out that it actually can :P
- it works better if you make it compare images directly, vs when you tell it to rate the images.
- rating images works somewhat (bad images get consistently low scores), but the results vary with each run, so it's not very reliable. I also didn't think the "best photos" according to the ranking were actually the best.

Overall, I think this script gives you a good starting point.
I made it keep a bit more photos than I intended to use, then dropped some that I didn't like and copied a few that I liked,
but were not selected by the model.

If the API limits were ever to increase enough to run the requests in parallel, I think this could feasibly run in a minute or two.
I tried a [commercial application for photo culling][aftershoot], and it took about 5 minutes to process 800 photos and only dropped around 400 of them,
leaving me to manually go through the rest. I think this is better and definitely much cheaper (it cost about $15 for the set of 2000 photos, and that's with the massive number of retries I encountered).

## Installation and dependencies

The script is written in ruby, so you will need bundler to install dependencies and `imagemagick` for image resizing.

```bash
git clone https://github.com/psyho/photos-selector.git
cd photos-selector
sudo apt install imagemagick
bundle install
echo "OPENAI_API_KEY=<secret>" > .env
```

## Usage

```bash
./bin/filter-in-batches <path-to-images-dir> <path-to-output-dir> <desired-number-of-images>
```

[aftershoot]: https://aftershoot.com/
