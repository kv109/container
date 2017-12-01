#!/usr/bin/env ruby

require 'optparse'

CURRENT_FILENAME = __FILE__.split('/').last
REPO_HOST        = '842640438826.dkr.ecr.us-west-2.amazonaws.com'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./#{CURRENT_FILENAME} [options]"

  opts.on('-i', '--image=IMAGE_NAME', '(example: --image=platform-os-postgres:latest)') do |v|
    options[:image] = v
  end
end.parse!

image_name = options[:image]

if image_name.nil?
  puts "Missing --image argument, see:\n#{CURRENT_FILENAME} --help"
  exit 1
end

docker_image_uri = "#{REPO_HOST}/platform-os-postgres:latest"

[
  '$(aws ecr get-login --no-include-email --region us-west-2)',
  "docker tag #{image_name} #{docker_image_uri}",
  "docker push #{docker_image_uri}"
].each do |command|
  puts "Executing: #{command} ..."
  system command
  puts '...done!'
end
