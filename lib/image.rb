require_relative 'list_images'

require 'mini_magick'
require "fileutils"

class Image
  def self.all_in_directory(directory)
    list_jpegs(directory).map do |image|
      new(image)
    end
  end

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def to_s
    @path
  end

  def name
    @name ||= File.basename(@path)
  end

  def resized_path(cache_dir = "/tmp/image-cache")
    "#{cache_dir}/#{name}".tap do |path|
      resize(path) unless File.exist?(path)
    end
  end

  def encoded
    Base64.strict_encode64(File.binread(resized_path))
  end

  private

  def resize(output_path)
    image = MiniMagick::Image.open(@path)

    # Calculate the scaling factor
    longest_edge = [image.width, image.height].max
    scale_factor = 512.0 / longest_edge

    # Resize the image
    image.resize "#{(image.width * scale_factor).to_i}x#{(image.height * scale_factor).to_i}"

    FileUtils.mkdir_p(File.dirname(output_path))

    # Save the resized image
    image.write output_path
  end
end
