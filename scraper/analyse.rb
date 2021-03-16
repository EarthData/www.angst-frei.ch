#!/usr/bin/env ruby

require 'yaml'

files = Dir.glob("../_posts/*.md")

files.each do |file|
  thing = YAML.load_file(file)
  thing['categories'] = thing['categories'].split(",") if thing['categories'].is_a?(String)
  if thing['categories'].length() == 1 and thing['categories'][0] == "Medien"
    puts file
    puts thing['categories'][0]
  end
end

