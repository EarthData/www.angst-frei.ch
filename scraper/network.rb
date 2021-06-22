#!/usr/bin/env ruby

require 'yaml'
require 'csv'

require File.join(__dir__, 'lib/tools')

files = Dir.glob("../_posts/*.md")

def build_network(files, year, part, month, all)

  graph_categories = true
  graph_tags = true

  network_nodes = Hash.new
  network_edges = Array.new

  counter = 1
  node_count = 1
  edges_count = 1

  files.each do |filename|

    meta_data = YAML.load_file(filename)

    next if meta_data['published'] = false

    article_year = meta_data['date'].strftime("%Y").to_i
    article_month = meta_data['date'].strftime("%m").to_i

    next if (year != article_year or !month.include?(article_month)) and !all

    puts "File: #{filename} (#{counter}) (#{year}) (#{month})"
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
      network_nodes[file_name]['group'] = meta_data['title']
      article_id = node_count
      node_count += 1
    end
  
    if graph_categories
      meta_data['categories'].each do |category|
        next if category.match(/^(MSM|Video)$/)
        if network_nodes[category]
          #puts "#{category} already exists"
          network_nodes[category]['value'] += 1
          network_edges <<  { "source" => network_nodes[category]['id'], "target" => article_id, "title" => meta_data['title'], "group" => category, "value" => 2 }
          edges_count += 1
        else
          network_nodes[category] = Hash.new
          network_nodes[category]['id'] = node_count
          network_nodes[category]['title'] = category
          network_nodes[category]['value'] = 1
          network_nodes[category]['group'] = category
          network_edges <<  { "source" => node_count, "target" => article_id, "title" => meta_data['title'], "group" => category, "value" => 2 }
          node_count += 1
        end
      end
    end

    if graph_tags
      meta_data['tags'].each do |tag|
        next if tag.match(/^(paywall|pdf|pinned|intern)$/)
        if network_nodes[tag]
          #puts "#{tag} already exists"
          network_nodes[tag]['value'] += 1
          network_edges <<  { "source" => network_nodes[tag]['id'], "target" => article_id, "title" => meta_data['title'], "group" => tag, "value" => 1 }
          edges_count += 1
        else
          network_nodes[tag] = Hash.new
          network_nodes[tag]['id'] = node_count
          network_nodes[tag]['title'] = tag
          network_nodes[tag]['value'] = 1
          network_nodes[tag]['group'] = tag
          network_edges <<  { "source" => node_count, "target" => article_id, "title" => meta_data['title'], "group" => tag, "value" => 1 }
          node_count += 1
        end
      end
    end
  
  end

  all ? node_file_name = "../_data/network-link-nodes.csv" : node_file_name = "../_data/network-link-nodes-#{year}-#{part}.csv"
  all ? edge_file_name = "../_data/network-link-edges.csv" : edge_file_name = "../_data/network-link-edges-#{year}-#{part}.csv"

  CSV.open(node_file_name, "wb", { :force_quotes => true }) do |csv|  
    csv << ["id", "title", "value", "group"]
    network_nodes.each do |node, values|
      csv << [values['id'], values['title'], values['value'], values['group']]  
    end
  end  

  CSV.open(edge_file_name, "wb") do |csv|  
    csv << ["from", "to", "title", "group", "value"]
    network_edges.each do |edge|
      csv << [edge['source'], edge['target'], edge['title'], edge['group'], edge['value']]  
    end
  end  

end

[2019, 2020, 2021].each do |year|
  [[1,2,3,4,5,6], [7,8,9,10,11,12]].each do |month|
    if month[0] == 1
      part = 1
    else 
      part = 2
    end
    puts year
    puts part
    puts month
    build_network(files, year, part, month, false)
  end
end

build_network(files, 0, 0, 0, true)

