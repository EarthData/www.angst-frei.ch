#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/tools')
files = Dir.glob("../_studies/*.md")

def build_network(files)

  studies = Hash.new
  files.each do |filename|

    meta_data = YAML.load_file(filename)

    file_name = filename.split('/').last
    file_name = File.basename(file_name,File.extname(file_name))

    studies[file_name] = Hash.new
    studies[file_name]['date'] = meta_data['date']
    studies[file_name]['titel'] = meta_data['de']['subtitle']
    studies[file_name]['title'] = meta_data['en']['subtitle']
    studies[file_name]['group'] = meta_data['group']


  end

  studies = studies.sort_by { |k, v| v['date'] }

  studies_file_name = "../tables/studies.csv"

  fileHandle = File.new(studies_file_name, "r+")
  if fileHandle
    fileHandle.syswrite("|Datum|Titel|Title|Kategorie|\n")
    fileHandle.syswrite("|-----|-----|-----|---------|\n")
    studies.each do |node, values|
      fileHandle.syswrite("|#{values['date']}|#{values['titel']}|#{values['title']}|#{values['group']}|\n")
    end
  else
    puts "Not able to access the file"
  end

end

build_network(files)

