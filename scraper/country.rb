#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/scraper')
require File.join(__dir__, 'lib/tools')

scrape = Scraper.new
tools = Tools.new
counter = 1

config = YAML.load_file("config.yml")

files = Dir.glob("../_posts/*-berliner-zeitung_*.md")
#files = Dir.glob("../_posts/2021-04-29-nach*.md")
#files = Dir.glob("../_posts/*.md")

parameters = ['date', 'redirect', 'title', 'subtitle', 'description', 'timeline', 'country', 'persons', 'categories', 'tags', 'filename', 'content']

files.each do |filename|

  puts "File: #{filename} (#{counter})"
  counter += 1

  meta_data = YAML.load_file(filename)
  file = File.open(filename)
  file_data = file.read
  file_data = file_data.gsub!(/\A---(.|\n)*?---/, '')
  file_data = file_data.gsub(/\n+|\r+/, "\n").squeeze("\n").strip

  file_date = filename.match /([0-9]{4}\-[0-9]{2}\-[0-9]{2})/

  file_name = filename.split('/').last
  meta_data['filename'] = File.basename(file_name,File.extname(file_name))

  new_file = meta_data

  parameters.each do |parameter|
    if parameter == 'country'
      puts new_file[parameter]
      if !new_file[parameter].kind_of?(Array)
        puts "Changing country to array"
        new_file[parameter] = [new_file[parameter].to_s].to_s.gsub('"', '')
      end
      puts new_file[parameter]
    elsif parameter == 'content'
      new_file[parameter] = file_data
    end
  end

  tools.write_file(new_file, false, false)
  #if meta_data.to_s == new_file.to_s
  #  puts "Files are equal"
  #else
  #end

end

