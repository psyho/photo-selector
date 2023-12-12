def each_jpeg(dir)
  extensions = %w[.jpg .JPG .jpeg .JPEG]
  Dir.glob("#{dir}/**/*") do |image|
    extension = File.extname(image)
    yield image if extensions.include?(extension)
  end
end
