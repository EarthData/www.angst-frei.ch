#!/usr/bin/env ruby

require File.join(__dir__, 'lib/scraper')
require File.join(__dir__, 'lib/tools')

if !ARGV[0]
  puts "no url specified"
  exit 0
end

url = ARGV[0]
date = ARGV[1]

puts "Scraping #{url} ..."

site_data = Scraper.new.scrape_url(url, date, true)
Tools.new.write_file(site_data, true, false)

