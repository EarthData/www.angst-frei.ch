#!/usr/bin/env ruby

require 'yaml'
require 'csv'

require File.join(__dir__, 'lib/tools')

counter = 1

files = Dir.glob("../_posts/*.md")

network_nodes = Hash.new
network_edges = Array.new

node_count = 1
edges_count = 1

files.each do |filename|

  puts "File: #{filename} (#{counter})"
  counter += 1

  break if counter > 800

  meta_data = YAML.load_file(filename)
  file_name = filename.split('/').last
  file_name = File.basename(file_name,File.extname(file_name))

  file_date = file_name.match /([0-9]{4}\-[0-9]{2}\-[0-9]{2})/
  #file_name = file_name.match /[0-9]{4}\-[0-9]{2}\-[0-9]{2}\-(.*)$/
  if network_nodes[meta_data['subtitle']]
    puts "#{meta_data['subtitle']} already exists"
  else
    network_nodes[meta_data['subtitle']] = Hash.new
    network_nodes[meta_data['subtitle']]['id'] = node_count
    network_nodes[meta_data['subtitle']]['value'] = 1
    article_id = node_count
    node_count += 1
  end
  
  meta_data['categories'].each do |category|
    if network_nodes[category]
      #puts "#{category} already exists"
      network_nodes[category]['value'] += 1
      network_edges <<  { "source" => article_id, "target" => network_nodes[category]['id'], "value" => 3 }
      edges_count += 1
    else
      network_nodes[category] = Hash.new
      network_nodes[category]['id'] = node_count
      network_nodes[category]['value'] = 1
      network_edges <<  { "source" => article_id, "target" => node_count, "value" => 3 }
      node_count += 1
    end
  end

  meta_data['tags'].each do |tag|
    next if tag == "wochenblick"
    if network_nodes[tag]
      #puts "#{tag} already exists"
      network_nodes[tag]['value'] += 1
      network_edges <<  { "source" => article_id, "target" => network_nodes[tag]['id'], "value" => 1 }
      edges_count += 1
    else
      network_nodes[tag] = Hash.new
      network_nodes[tag]['id'] = node_count
      network_nodes[tag]['value'] = 1
      network_edges <<  { "source" => article_id, "target" => node_count, "value" => 1 }
      node_count += 1
    end
  end
  
end


CSV.open("../_data/network-link-nodes.csv", "wb") do |csv|  
  csv << ["id", "label", "value"]
  network_nodes.each do |node, values|
    csv << [values['id'], node, values['value']]  
  end
end  

CSV.open("../_data/network-link-edges.csv", "wb") do |csv|  
  csv << ["from", "to", "value"]
  network_edges.each do |edge|
    csv << [edge['source'], edge['target'], edge['value']]  
  end
end  

#puts "id,label,image,group"
#puts network_nodes
#puts network_edges
