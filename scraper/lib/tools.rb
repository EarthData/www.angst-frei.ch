
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
  def write_file(site_data)

    if(File.exist?("../_posts/#{site_data['filename']}.md"))
      puts "File #{site_data['filename']}.md already exists in ../_posts"
      exit 0
    end
    tags = site_data['tags'].join(', ')

    content = %{---
date:          #{site_data['date']}
redirect:      #{site_data['redirect']}
title:         #{site_data['title']}
subtitle:      '#{site_data['subtitle']}'
country:       #{site_data['country']}
categories:    []
tags:          [#{tags}]
---
}

    puts "Writing: #{site_data['filename']}.md\n#{content}"
    File.write("#{site_data['filename']}.md", content)
  end
end
