#!/usr/bin/env ruby

require 'optparse'

CURRENT_FILENAME = __FILE__.split('/').last
REPO_HOSTS       = { 'staging' => '842640438826.dkr.ecr.us-west-2.amazonaws.com' }

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./#{CURRENT_FILENAME} [options]"

  opts.on('-e', '--env=ENVIRONMENT', '(example: --env=staging)') do |v|
    options[:environment] = v
  end

  opts.on('-i', '--image=IMAGE_NAME', '(example: --image=platform-os:latest)') do |v|
    options[:image] = v
  end
end.parse!

environment = options[:environment]
image_name  = options[:image]

if environment.nil?
  puts "Missing --env argument, see:\n#{CURRENT_FILENAME} --help"
  exit 1
end

if image_name.nil?
  puts "Missing --image argument, see:\n#{CURRENT_FILENAME} --help"
  exit 1
end

unless image_name.split(':').size == 2
  puts "--image argument requires following format: \"{name}:{tag}\", for example \"--image=platform-os:latest\""
  exit 1
end

tag = image_name.split(':').last

docker_image_uri = "#{REPO_HOSTS.fetch(environment)}/platform-os-web:#{tag}"

[
  '$(aws ecr get-login --no-include-email --region us-west-2)',
  "docker tag #{image_name} #{docker_image_uri}",
  "docker push #{docker_image_uri}"
].each do |command|
  puts "Executing: #{command} ..."
  system command
  puts '...done!'
end
