#!/usr/bin/env ruby

require 'yaml'
require 'csv'

require File.join(__dir__, 'lib/tools')

counter = 1

files = Dir.glob("../_posts/*.md")

network_nodes = Array.new
network_edges = Array.new

node_count = 1
edges_count = 1

files.each do |filename|

  puts "File: #{filename} (#{counter})"
  counter += 1

  #break if counter > 1100

  meta_data = YAML.load_file(filename)
  file_name = filename.split('/').last
  file_name = File.basename(file_name,File.extname(file_name))

  file_date = file_name.match /([0-9]{4}\-[0-9]{2}\-[0-9]{2})/
  #file_name = file_name.match /[0-9]{4}\-[0-9]{2}\-[0-9]{2}\-(.*)$/
  if network_nodes.detect {|node| node["label"] == file_name }
    puts "#{file_name} already exists"
  else
    network_nodes <<  { "label" => meta_data['subtitle'], "id" => node_count, "value" => 1 }
    article_id = node_count
    node_count += 1
  end
  
  meta_data['categories'].each do |category|
    if network_nodes.detect {|node| node["label"] == category }
      node = network_nodes.detect {|node| node["label"] == category }
      #puts "#{category} already exists"
      network_edges <<  { "id" => edges_count, "source" => article_id, "target" => node['id'] }
      edges_count += 1
    else
      network_nodes <<  { "label" => category, "id" => node_count, "value" => 3 }
      network_edges <<  { "id" => edges_count, "source" => article_id, "target" => node_count }
      node_count += 1
    end
  end

  meta_data['tags'].each do |tag|
    next if tag == "wochenblick"
    if network_nodes.detect {|node| node["label"] == tag }
      node = network_nodes.detect {|node| node["label"] == tag }
      #puts "#{category} already exists"
      network_edges <<  { "id" => edges_count, "source" => article_id, "target" => node['id'] }
      edges_count += 1
    else
      network_nodes <<  { "label" => tag, "id" => node_count, "value" => 2 }
      network_edges <<  { "id" => edges_count, "source" => article_id, "target" => node_count }
      node_count += 1
    end
  end
  
end

CSV.open("../_data/network-link-nodes.csv", "wb") do |csv|  
  csv << ["id", "label", "value"]
  network_nodes.each do |node|
    csv << [node['id'], node['label'], node['value']]  
  end
end  

CSV.open("../_data/network-link-edges.csv", "wb") do |csv|  
  csv << ["id", "from", "to"]
  network_edges.each do |edge|
    csv << [edge['id'], edge['source'], edge['target']]  
  end
end  

#puts "id,label,image,group"
#puts network_nodes
#puts network_edges
