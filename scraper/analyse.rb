#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/scraper')
require File.join(__dir__, 'lib/tools')

#puts "Scraping #{url} ..."
scrape = Scraper.new
#tools = Tools.new
#site_data = scrape.scrape_url(url, date)
#tools.write_file(site_data)

files = Dir.glob("../_posts/*.md")

files.each do |file|

  puts "\nFile: #{file}"

  meta_data = YAML.load_file(file)
  site_data = scrape.scrape_url(meta_data['redirect'], meta_data['date'].to_s)
  
  puts meta_data['redirect']
  puts site_data['redirect']

  #meta_data['categories'] = meta_data['categories'].split(",") if meta_data['categories'].is_a?(String)
  #if meta_data['categories'].length() == 1 and meta_data['categories'][0] == "Medien"
  #  puts file
  #  puts meta_data['categories'][0]
  #end
end

