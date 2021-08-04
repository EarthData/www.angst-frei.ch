#!/usr/bin/env ruby

require 'yaml'

require File.join(__dir__, 'lib/tools')

files = Dir.glob("../_posts/*.md")

def build_network(files)

  graph_country = true
  graph_year = true

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
      network_nodes[file_name]['title'] = meta_data['subtitle']
      #network_nodes[file_name]['title'] = "<a href=\"#{meta_data['redirect']}\">#{meta_data['subtitle']}</a>"
      if meta_data['redirect']
        network_nodes[file_name]['link'] = meta_data['redirect']
      elsif meta_data['credit']
        network_nodes[file_name]['link'] = meta_data['credit']
      else
        network_nodes[file_name]['link'] = ""
      end
      network_nodes[file_name]['group'] = meta_data['title']
      article_id = node_count
      node_count += 1
    end
  
    if graph_country and meta_data['country']
      meta_data['country'].each do |country|
        if network_nodes[country]
          #puts "#{meta_data['subtitle']} already exists"
          network_nodes[country]['value'] += 1
          network_edges <<  { "source" => network_nodes[country]['id'], "target" => article_id, "title" => meta_data['title'], "group" => country, "value" => 2 }
          edges_count += 1
        else
          network_nodes[country] = Hash.new
          network_nodes[country]['id'] = node_count
          network_nodes[country]['title'] = country
          network_nodes[country]['value'] = 1
          network_nodes[country]['link'] = "" 
          network_nodes[country]['group'] = country
          network_edges <<  { "source" => node_count, "target" => article_id, "title" => meta_data['title'], "group" => country, "value" => 2 }
          node_count += 1
        end
      end
    end

    if graph_year
      if network_nodes[year]
        #puts "#{meta_data['subtitle']} already exists"
        network_nodes[year]['value'] += 1
        network_edges <<  { "source" => network_nodes[year]['id'], "target" => article_id, "title" => meta_data['title'], "group" => year, "value" => 2 }
        edges_count += 1
      else
        network_nodes[year] = Hash.new
        network_nodes[year]['id'] = node_count
        network_nodes[year]['title'] = year
        network_nodes[year]['value'] = 1
        network_nodes[year]['link'] = "" 
        network_nodes[year]['group'] = year
        network_edges <<  { "source" => node_count, "target" => article_id, "title" => meta_data['title'], "group" => year, "value" => 2 }
        node_count += 1
      end
    end
  end

  node_file_name = "../_data/network-country-nodes.csv"
  edge_file_name = "../_data/network-country-edges.csv"

  Tools.new.write_csv(network_nodes, network_edges, node_file_name, edge_file_name)

end

build_network(files)

