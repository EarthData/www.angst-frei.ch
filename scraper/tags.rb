#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/tools')

counter = 1
debug = false

config = YAML.load_file("config.yml")

tools = Tools.new

files = Dir.glob("../_posts/*-tagesanzeiger_*.md")
files = Dir.glob("../_posts/*.md")

task = ""
#  task = "check_categories"
#  task = "check_tags"

files.each do |filename|
  puts "File: #{filename}"

  meta_data = YAML.load_file(filename)

  file = File.open(filename)
  file_data = file.read
  file_data = file_data.gsub!(/\A---(.|\n)*?---/, '')
  file_data = file_data.gsub(/\n+|\r+/, "\n").squeeze("\n").strip
  meta_data['content'] = file_data

  file_name = filename.split('/').last
  meta_data['filename'] = File.basename(file_name,File.extname(file_name))

  domainmatches = filename.match /[0-9]{4}\-[0-9]{2}\-[0-9]{2}\-([a-z-0-9]+)_/
  domain = domainmatches[1]
  
  #domain = tools.get_sitename(meta_data['redirect'], debug)
  #puts domain
 
  if task == "check_categories"
    if config['category'][domain] and !meta_data['categories'].include?(config['category'][domain])
      puts "File: #{filename} (#{counter})"
      puts "#{config['category'][domain]} not found"
      meta_data['categories'].push(config['category'][domain])
    end
    if meta_data['categories'].length == 1
      puts "File: #{filename} (#{counter})"
      puts "just 1 category"
      counter += 1
    end
  end

  if task == "check_tags"
    if meta_data['tags'].length == 1
      puts "File: #{filename} (#{counter})"
      puts "just 1 tag"
      counter += 1
    end
    next
  end


  #if meta_data['categories'].include?("Manipulation") and meta_data['categories'].length == 1
  #  puts "File: #{filename} (#{counter})"
  #  counter += 1
  #end

  if meta_data['tags'].include?("indien")
  #if meta_data['categories'].include?("Schulen")
    puts "File: #{filename} (#{counter})"
    puts meta_data['tags']
    #puts meta_data['categories']
    meta_data['tags'].delete_at(meta_data['tags'].index("indien"))
    #meta_data['categories'].delete_at(meta_data['categories'].index("Schulen"))
    puts meta_data['tags']
    #puts meta_data['categories']
    #meta_data['tags'].push("schnelltest")
    #meta_data['categories'].push("Schule")
    meta_data['country'] = "IN"
    #puts meta_data['tags']
    #puts meta_data['categories']
    counter += 1

    if file_data != ""
      tools.write_file(meta_data, false, file_data)
    else
      tools.write_file(meta_data, false, false)
    end

  end

end

