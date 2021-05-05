#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/scraper')
require File.join(__dir__, 'lib/tools')

scrape = Scraper.new
tools = Tools.new
counter = 1

config = YAML.load_file("config.yml")

files = Dir.glob("../_posts/*-achgut_*.md")
#files = Dir.glob("../_posts/2021-03-*.md")
#files = Dir.glob("../_posts/*.md")

parameters = ['date', 'redirect', 'title', 'subtitle', 'timeline', 'country', 'persons', 'categories', 'tags', 'filename']

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

  if file_date.to_s != meta_data['date'].to_s
    puts "filedate :#{file_date}: and metadate :#{meta_data['date']}: differ"
    exit
  end

  if file_data != ""
    puts "File has data: #{file_data}"
    next
  end
  
  if !meta_data['redirect']
    puts "no redirect found"
    next
  end

#  if meta_data['title'].match?(/reitschuster|Wochenblick|Tagesanzeiger|linth24|Die Ostschweiz|ScienceFiles|FM1 Today/)
#    next
#  end

  # temporary remove NZZ
  if meta_data['title'].match?(/SWR|European Medicines Agency|FM1 Today|Handelsblatt/)
    next
  end

  site_data = scrape.scrape_url(meta_data['redirect'], meta_data['date'].to_s, false)
  
#  if meta_data.keys != site_data.keys
#    puts "Keys differ: #{meta_data.keys} #{site_data.keys}"
#  end

  new_file = Hash.new

  parameters.each do |parameter|
    if parameter == 'tags'
      if meta_data[parameter].include?(site_data['domaintag'])
        puts "sitename #{site_data['domaintag']} found in tags"
        meta_data[parameter].delete_at(meta_data[parameter].index(site_data['domaintag']))
      end
      new_file[parameter] = meta_data[parameter]
    elsif parameter == 'categories'
      if !meta_data[parameter].kind_of?(Array)
        puts "Changing catgories to array"
        new_file[parameter] = [meta_data[parameter]]
      else
        new_file[parameter] = meta_data[parameter]
      end
    elsif parameter == 'timeline' and meta_data[parameter] == false
      puts "deleting timeline"
    elsif parameter == 'timeline' and !meta_data[parameter]
      #puts "no timeline"
    elsif parameter == 'timeline' and meta_data[parameter]
      new_file[parameter] = meta_data[parameter]
      puts "add timeline"
    elsif parameter == 'subtitle' and config[parameter][meta_data['title']] and config[parameter][meta_data['title']] == "ignore"
      new_file[parameter] = meta_data[parameter]
      puts "ignoring subtitle"
    elsif parameter == 'persons' and !meta_data[parameter]
      #puts "no persons"
    elsif parameter == 'persons' and meta_data[parameter]
      if !meta_data[parameter].kind_of?(Array)
        puts "Changing persons to array"
        new_file[parameter] = [meta_data[parameter]]
      else
        new_file[parameter] = meta_data[parameter]
      end
    elsif parameter == 'filename' and meta_data['filename'].to_s != site_data['filename'].to_s
      puts "change filename: mv ../_posts/#{meta_data[parameter]}.md ../_posts/#{site_data[parameter]}.md"
      new_file[parameter] = site_data[parameter]
    elsif meta_data[parameter].to_s != site_data[parameter].to_s
      #puts "#{parameter}: changing :#{meta_data[parameter]}: to :#{site_data[parameter]}:"
      new_file[parameter] = site_data[parameter]
    else
      new_file[parameter] = site_data[parameter]
    end
  end

  tools.write_file(new_file, false, false)
  #if meta_data.to_s == new_file.to_s
  #  puts "Files are equal"
  #else
  #end

end

