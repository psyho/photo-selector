def each_jpeg(dir)
  extensions = %w[.jpg .JPG .jpeg .JPEG]
  Dir.glob("#{dir}/**/*") do |image|
    extension = File.extname(image)
    yield image if extensions.include?(extension)
  end
end

def list_jpegs(dir)
  images = []
  each_jpeg(dir) do |image|
    images << image
  end
  images
end
