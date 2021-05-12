#!/usr/bin/env ruby

require File.join(__dir__, 'lib/archive')
require File.join(__dir__, 'lib/tools')

if !ARGV[0]
  puts "no url specified"
  exit 0
end

url = ARGV[0]
date = ARGV[1]

debug = 1

puts "Making pdf of #{url} ..."

tools = Tools.new

domain = tools.get_sitename(url, debug)
document = tools.get_filename(url, domain, debug)
filename = "#{date}-#{domain}_#{document}"
Archive.new.pdf(url, filename)

