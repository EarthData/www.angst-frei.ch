#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/scraper')
require File.join(__dir__, 'lib/tools')

scrape = Scraper.new
#tools = Tools.new
#site_data = scrape.scrape_url(url, date)
#tools.write_file(site_data)

files = Dir.glob("../_posts/*-rt_*.md")

parameters = ['date', 'redirect', 'title', 'timeline', 'subtitle', 'categories', 'tags']

files.each do |file|

  puts "File: #{file}"

  meta_data = YAML.load_file(file)
  file = File.open(file)
  file_data = file.read
  file_data = file_data.gsub!(/\A---(.|\n)*?---/, '')
  file_data = file_data.gsub(/\n+|\r+/, "\n").squeeze("\n").strip

  if file_data != ""
    puts "File has data: #{file_data}"
    next
  end
  
  #puts meta_data
  #puts ":#{file_data}:"

  if !meta_data['redirect']
    puts "no redirect found"
    next
  end

  site_data = scrape.scrape_url(meta_data['redirect'], meta_data['date'].to_s, false)
  
  if meta_data.keys != site_data.keys
    puts "Keys differ: #{meta_data.keys} #{site_data.keys}"
  end

  parameters.each do |parameter|
    if meta_data[parameter].to_s != site_data[parameter].to_s
      puts "#{parameter} not equal"
      puts "File: :#{meta_data[parameter]}:"
      puts "URL: :#{site_data[parameter]}:"
    end
  end

  #if meta_data['redirect'] != site_data['redirect']
  #  puts "redirect not equal"
  #  puts "File: #{meta_data['redirect']}"
  #  puts "URL: #{site_data['redirect']}"
  #end

  #if meta_data['title'] != site_data['title']
  #  puts "title not equal"
  #  puts "File: #{meta_data['title']}"
  #  puts "URL: #{site_data['title']}"
  #end

  #if meta_data['subtitle'] != site_data['subtitle']
  #  puts "subtitle not equal"
  #  puts "File: #{meta_data['subtitle']}"
  #  puts "URL: #{site_data['subtitle']}"
  #end

  #meta_data['categories'] = meta_data['categories'].split(",") if meta_data['categories'].is_a?(String)
  #if meta_data['categories'].length() == 1 and meta_data['categories'][0] == "Medien"
  #  puts file
  #  puts meta_data['categories'][0]
  #end
end

