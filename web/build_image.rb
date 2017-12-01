#!/usr/bin/env ruby

require 'optparse'

ALLOWED_ENVS                       = %w[staging]
CURRENT_FILENAME                   = __FILE__.split('/').last
DEFAULT_BRANCH                     = 'release_candidate'
DEFAULT_TAG                        = 'latest'
DIR_WITH_WEB_APP                   = 'src'
PLATFORM                           = `uname`.match(/.*Darwin.*/) ? :mac : :linux
RELATIVE_PATH_TO_PUSH_IMAGE_SCRIPT = './push_image.rb'
VAULT_CONTAINER_NAME               = 'vault-platform-os'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./#{CURRENT_FILENAME} [options]"

  opts.on('-b', '--branch=BRANCH', "Set branch (default: \"#{DEFAULT_BRANCH}\")") do |v|
    options[:branch] = v
  end

  opts.on('-p', '--push=ENVIRONMENT', 'Push image to aws on given ENVIRONMENT (example: --push=staging)') do |v|
    options[:push] = v
  end

  opts.on('-t', '--tag=TAG', "Set tag for the image (default: \"#{DEFAULT_TAG}\")") do |v|
    options[:tag] = v
  end
end.parse!


def linux?
  PLATFORM == :linux
end

def mac?
  PLATFORM == :mac
end

def in_web_app_dir(command)
  `cd #{DIR_WITH_WEB_APP} && #{command}`
end

def set_branch(branch:)
  in_web_app_dir "git checkout #{branch}"
end

def working_dir_dirty?
  res = in_web_app_dir 'git status'
  res.match('nothing to commit').nil?
end

def vault_host
  if mac?
    `ifconfig en0 | grep "inet " | cut -d " " -f2`.chomp
  else
    '172.17.0.1'
  end
end

branch = options[:branch] || DEFAULT_BRANCH
# TODO: if branch == 'master' then require_version
push       = options[:push]
tag        = options[:tag] || DEFAULT_TAG
image_name = "platform-os:#{tag}"
vault_host = vault_host()

if push && !ALLOWED_ENVS.include?(push)
  puts "--push has to be in #{ALLOWED_ENVS}"
  exit 1
end

if working_dir_dirty?
  raise "Web app working dir (./#{DIR_WITH_WEB_APP}) needs to be clean. All your changes needs to be committed!"
end

set_branch(branch: branch)

[
  "docker stop #{VAULT_CONTAINER_NAME}",
  "docker rm #{VAULT_CONTAINER_NAME}",
  "docker run  --name #{VAULT_CONTAINER_NAME} -d -p #{vault_host}:14242:3000 -v ~/.ssh:/vault/.ssh dockito/vault",
].each do |command|
  puts "Executing: #{command} ..."
  system command
  puts '...done!'
end

build_command = "docker build --build-arg VAULT_HOST=#{vault_host} -t #{image_name} ."
puts "Executing: #{build_command} ..."
build_command_success = system(build_command)
puts '...done!'

[
  "docker stop #{VAULT_CONTAINER_NAME}",
  "docker rm #{VAULT_CONTAINER_NAME}"
].each do |command|
  puts "Executing: #{command} ..."
  system command
  puts '...done!'
end

unless build_command_success
  puts 'Building image failed, exiting.'
  exit 1
end

if push
  system "#{RELATIVE_PATH_TO_PUSH_IMAGE_SCRIPT} --image=#{image_name} --env=#{push}"
end
