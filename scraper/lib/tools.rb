
require 'open-uri'

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

class Tools

  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end

  def get_sitename(url, debug)

    config = YAML.load_file("config.yml")

    uri = URI(url).hostname
    puts "URI: #{uri}" if debug

    if config['uri'][uri] and  config['uri'][uri] == "first"
      domain = URI(url).hostname.split('.').first
    elsif config['uri'][uri] and  config['uri'][uri] == "second"
      domain = URI(url).hostname.split('.')[1]
    else
      domain = URI(url).hostname.split('.').last(2).first
    end
    puts "Domain: #{domain}" if debug

    return domain

  end

  def write_file(site_data, warn_on_existing, file_data)

    if(File.exist?("../_posts/#{site_data['filename']}.md") and warn_on_existing)
      puts "File ../_posts/#{site_data['filename']}.md already exists"
      exit 0
    end
    tags = site_data['tags'].join(', ')
    categories = site_data['categories'].join(', ')
    persons = site_data['persons'].join(', ') if site_data['persons']

    content = %{---
date:          #{site_data['date']}
redirect:      #{site_data['redirect']}
title:         #{site_data['title']}
subtitle:      '#{site_data['subtitle']}'
country:       #{site_data['country']}
}
    if site_data['timeline'] 
      content += %{timeline:      #{site_data['timeline']}
}
    end
    if persons 
      content += %{persons:       [#{persons}]
}
    end

    content += %{categories:    [#{categories}]
tags:          [#{tags}]
---
}

    if file_data
      content += file_data
    end

    if warn_on_existing
      puts "Writing: #{site_data['filename']}.md\n#{content}"
    end

    File.write("#{site_data['filename']}.md", content)

    if !warn_on_existing
      file_diff1 = YAML.load_file("#{site_data['filename']}.md")
      file_diff2 = YAML.load_file("../_posts/#{site_data['filename']}.md")
      if file_diff1 == file_diff2
        #puts "Files #{site_data['filename']}.md are identical, deleting local copy"
        File.delete("#{site_data['filename']}.md")
      else
        puts "Diff:"
        puts file_diff1.to_a - file_diff2.to_a
        puts file_diff2.to_a - file_diff1.to_a
      end
    end
  end
end
