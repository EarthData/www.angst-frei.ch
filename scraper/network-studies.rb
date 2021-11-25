#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/tools')

files = Dir.glob("../_studies/*.md")

def build_network(files)

  network_nodes = Hash.new
  network_edges = Array.new

  counter = 1
  node_count = 1
  edges_count = 1

  files.each do |filename|

    meta_data = YAML.load_file(filename)

    next if meta_data['published'] = false

    year = meta_data['date'].strftime("%Y").to_i

    puts "File: #{filename} (#{counter})"
    counter += 1

    file_name = filename.split('/').last
    file_name = File.basename(file_name,File.extname(file_name))

    if network_nodes[file_name]
      puts "#{file_name} already exists"
    else
      network_nodes[file_name] = Hash.new
      network_nodes[file_name]['id'] = node_count
      network_nodes[file_name]['value'] = 1
      network_nodes[file_name]['title'] = meta_data['de']['subtitle']
      #network_nodes[file_name]['title'] = "<a href=\"#{meta_data['redirect']}\">#{meta_data['subtitle']}</a>"
      if meta_data['redirect']
        network_nodes[file_name]['link'] = meta_data['redirect']
      elsif meta_data['credit']
        network_nodes[file_name]['link'] = meta_data['credit']
      else
        network_nodes[file_name]['link'] = ""
      end
      network_nodes[file_name]['group'] = meta_data['group']
      article_id = node_count
      node_count += 1
    end

    group = meta_data['group']
    if network_nodes[group]
      #puts "#{meta_data['subtitle']} already exists"
      network_nodes[group]['value'] += 1
      network_edges <<  { "source" => network_nodes[group]['id'], "target" => article_id, "group" => group, "value" => 2 }
      edges_count += 1
    else
      network_nodes[group] = Hash.new
      network_nodes[group]['id'] = node_count
      network_nodes[group]['title'] = group
      network_nodes[group]['value'] = 1
      network_nodes[group]['link'] = "" 
      network_nodes[group]['group'] = group
      network_edges <<  { "source" => node_count, "target" => article_id, "group" => group, "value" => 2 }
      node_count += 1
    end

    title = meta_data['de']['title']
    if network_nodes[title]
      puts "#{meta_data['de']['title']} already exists"
      network_nodes[title]['value'] += 1
      network_edges <<  { "source" => network_nodes[title]['id'], "target" => article_id, "group" => title, "value" => 2 }
      edges_count += 1
    else
      network_nodes[title] = Hash.new
      network_nodes[title]['id'] = node_count
      network_nodes[title]['title'] = title
      network_nodes[title]['value'] = 1
      network_nodes[title]['link'] = "" 
      network_nodes[title]['group'] = title
      network_edges <<  { "source" => node_count, "target" => article_id, "group" => title, "value" => 2 }
      node_count += 1
    end

  end

  node_file_name = "../_data/network-studies-nodes.csv"
  edge_file_name = "../_data/network-studies-edges.csv"

  Tools.new.write_csv(network_nodes, network_edges, node_file_name, edge_file_name)

end

build_network(files)

