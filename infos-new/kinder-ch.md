---
layout:   page
title:    Infos
subtitle: Kinder
permalink: /infos/kinder
---

## Inhalt
{: .no_toc}

* TOC
{:toc}

{% assign entries = site.data.kinder | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}

{% for group in entries %}

## {{ group.name }}

  {% assign entries = group.items | sort: "Name" %}
  {% for entry in entries %}

### {{ entry['Name'] }}

    {% if entry['Beschreibung'] %}
{{ entry['Beschreibung'] }}
    {% endif %}

    {% if entry['Adresse'] %}
| {{ site.icons.address }}    |
    {%- assign lines = entry['Adresse'] | strip | replace: ", ", "," | split: "," -%}
    {%- for line in lines -%}
    {{ line | replace: "|", "\|" }}
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
|
    {%- endif %}

    {%- if entry['Webseite'] %}
| {{ site.icons.globe }}    |
    {%- assign websites = entry['Webseite'] | strip | replace: ", ", "," | split: "," -%}
    {%- for website in websites -%}
    [{{ website }}]({{ website }})
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
|
    {%- endif %}

    {%- if entry['Telegram'] %}
| {{ site.icons.telegram }}    |
    {%- assign chanels = entry['Telegram'] | strip | replace: ", ", "," | split: "," -%}
    {%- for chanel in chanels -%}
    [{{ chanel }}](https://t.me/{{ chanel }})
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
|
    {%- endif %}

    {%- if entry['Video'] %}
      {%- assign videos = entry['Video'] | strip | replace: ", ", "," | split: "," -%}
      {%- for video in videos -%}
        {%- assign videoparts = video | strip  | split: "|" -%}
        {%- assign platform = site.icons.globe -%}
        {%- if videoparts[0] == "youtube" -%}
          {%- assign platform = site.icons.youtube -%}
        {%- elsif  videoparts[0] == "dlive" -%}
          {%- assign platform = site.icons.dlive -%}
        {%- elsif  videoparts[0] == "bitchute" -%}
          {%- assign platform = site.icons.bitchute -%}
        {%- elsif  videoparts[0] == "lbry" -%}
          {%- assign platform = site.icons.lbry -%}
        {%- elsif  videoparts[0] == "odysee" -%}
          {%- assign platform = site.icons.odysee -%}
        {%- endif -%}
| {{ platform }} |[{{ videoparts[1] }}]({{ videoparts[1] }})|
      {% endfor -%}
    {% endif %}

  {% endfor %}

{% endfor %}

