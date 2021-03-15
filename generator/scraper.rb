#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'pdfkit'
require 'gastly'
require 'yaml'

class Scraper

  #url = "https://schweizerzeit.ch/absurde-corona-strafen/"
  def scrape_url(url, date) 

    config = YAML.load_file("config.yml")

    domain = URI(url).hostname.split('.').last(2).first
    puts "Domain: #{domain}"
    tld = URI(url).hostname.split('.').last.upcase
    puts "TLD: #{tld}"

    file = url.split('/').last
    document = File.basename(file,File.extname(file))

    if config['article'][domain] == "last"
      document = document.split('-').last
    elsif config['article'][domain] == "lastdot"
      document = url.split('.').last
    elsif config['article'][domain] == "first"
      document = document.split('-').first
    elsif config['article'][domain] == "previous"
      document = url.split('/')[url.split('/').length - 2]
    end

    puts "filename: #{document}"

    html = URI.open(url) 
    doc = Nokogiri::HTML(html)

    # sitename
    if config['sitename'][domain]
      site_name = config['sitename'][domain]
      puts "Site Name: #{site_name} (config)"
    elsif doc.at("meta[property='og:site_name']")
      site_name = doc.at("meta[property='og:site_name']")['content'].to_s.strip
      puts "Site Name: #{site_name} (og)"
    else
      site_name = domain
      puts "Site Name: #{site_name} (domain)"
    end

    # description
    if doc.at("meta[name='description']")
      description = doc.at("meta[name='description']")['content'].to_s.strip
      puts "Description: #{description} (meta)"
    elsif doc.at("meta[property='og:description']")
      description = doc.at("meta[property='og:description']")['content'].to_s.strip
      puts "Description: #{description} (og)"
    else 
      description = ""
      puts "Description not found"
    end

    # date
    if doc.at("meta[name='publish-date']")
      published_time = doc.at("meta[name='publish-date']")['content'].to_s.strip
      puts "Date: #{published_time} (meta publish-date)"
    elsif doc.at("meta[name='date']")
      published_time = doc.at("meta[name='date']")['content'].to_s.strip
      puts "Date: #{published_time} (meta date)"
    elsif doc.at("meta[property='article:published_time']")
      published_time = doc.at("meta[property='article:published_time']")['content'].to_s.strip
      puts "Date: #{published_time} (meta article:published_time)"
    elsif date
      published_time = date
    else 
      puts "no date found"
      exit 1
    end

    if config['tag'][domain]
      tag = config['tag'][domain]
    else
      tag = site_name.downcase
    end
 
    published_date = DateTime.parse(published_time)
    date  = published_date.strftime("%Y-%m-%d")

    # subtitle
    if doc.at("meta[property='og:title']")
      subtitle = doc.at("meta[property='og:title']")['content'].to_s.strip
      puts "Title: :#{subtitle}: (meta og:title)"
    elsif doc.xpath("/html/body//h1")
      subtitle = doc.xpath("/html/body//h1").first.text.strip.chomp
      puts "Title: :#{subtitle}: (first h1)"
    else
      puts "no title found"
      exit 1
    end

    if config['subtitle'][domain] && config['subtitle'][domain] = 'last'
      subtitle.gsub!(/[\s]+[|-][\s]+.*$/, "")
      puts "Change title to: #{subtitle}"
    end

    #title = '' if not (title.force_encoding("UTF-8").valid_encoding?)
    #title = title.chars.select(&:valid_encoding?).join
    #puts "Title: :" + title.delete!("^\u{0000}-\u{007F}") + ":"
    #puts "Title: :" + title.strip_control_characters + ":"
    #puts "Title: :" + title.strip_control_and_extended_characters + ":"

    filename = date + "-" + domain + "_" + document

    content = %{---
date:          #{date}
redirect:      #{url}
title:         #{site_name}
subtitle:      '#{subtitle}'
country:       #{tld}
categories:    []
tags:          [#{tag}]
---
}
    puts "Writing:\n#{content}"
    File.write("#{filename}.md", content)

    #  pdf
    #kit = PDFKit.new(url)
    #kit.to_file("#{filename}.pdf")

    # screeenshot
    #screenshot = Gastly.screenshot(url)
    #screenshot.browser_width = 1280 # Default: 1440px
    #screenshot.browser_height = 780 # Default: 900px
    #screenshot.timeout = 1000 # Default: 0 seconds
    #screenshot.phantomjs_options = '--ignore-ssl-errors=true'
    #image = screenshot.capture
    #image.crop(width: 1280, height: 780, x: 0, y: 0) # Crop with an offset
    ##image.resize(width: 1280, height: 780) # Creates a preview of the web page
    #image.format('png')
    #image.save("#{filename}.png")

  end
end

class String
  def strip_control_characters()
    chars.each_with_object("") do |char, str|
      str << char unless char.ascii_only? and (char.ord < 32 or char.ord == 127)
    end
  end
 
  def strip_control_and_extended_characters()
    chars.each_with_object("") do |char, str|
      str << char if char.ascii_only? and char.ord.between?(32,126)
    end
  end
end

url = ARGV[0]
date = ARGV[1]

puts "Scraping #{url} ..."
scrape = Scraper.new
scrape.scrape_url(url, date)
