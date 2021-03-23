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
scrape = Scraper.new
tools = Tools.new
site_data = scrape.scrape_url(url, date)
tools.write_file(site_data)

