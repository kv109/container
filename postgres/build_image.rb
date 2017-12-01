#!/usr/bin/env ruby

require 'optparse'

CURRENT_FILENAME                   = __FILE__.split('/').last
RELATIVE_PATH_TO_PUSH_IMAGE_SCRIPT = './push_image.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./#{CURRENT_FILENAME} [options]"

  opts.on('-p', '--push', 'Push image to aws') do |v|
    options[:push] = v
  end
end.parse!

push       = !!options[:push]
image_name = 'platform-os-postgres:latest'

build_command = "docker build . -t #{image_name}"
puts "Executing: #{build_command} ..."
build_command_success = system(build_command)
puts '...done!'

unless build_command_success
  puts 'Building image failed, exiting.'
  exit 1
end

if push
  system "#{RELATIVE_PATH_TO_PUSH_IMAGE_SCRIPT} --image=#{image_name}"
end
