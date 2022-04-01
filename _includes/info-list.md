{% for group in include.entries %}

## {{ group.name }}

  {% assign entries = group.items | sort: "Name" %}
  {% for entry in entries %}

  {%- assign kantone = entry['Kanton'] | strip | replace: ", ", "," | split: "," -%}
  {%- assign kantonsicons = "" | split: "," -%}
  {% if entry['Kanton'] %}
    {%- for kanton in kantone -%}
      {%- assign kantonsicon = "![" | append: kanton | append: "](/assets/img/flaggen/" | append: kanton | append: ".svg){:class='country-icon'}" -%}
      {%- assign kantonsicons = kantonsicons | push: kantonsicon -%}
    {%- endfor -%}
  {%- endif -%}

{% if entry['Land'] == "Schweiz" %}
  {% unless entry['Kanton'] %}
### {{ entry['Name'] }}
  {% else %}
    {%- assign icons = kantonsicons | join: " " %} 
### {{ icons }} {{ entry['Name'] }}
  {% endunless %}
{% elsif entry['Land'] %}
### {{ entry['Name'] }} ({{entry['Land']}})
{% else %}
### {{ entry['Name'] }}
{% endif %}

    {% if entry['Beschreibung'] %}
{{ entry['Beschreibung'] }}
    {% endif %}

<table>
  <tbody>
    {% if entry['Adresse'] %}
    <tr>
      <td>{{ site.icons.address }}</td>
      <td>
    {%- assign lines = entry['Adresse'] | strip | replace: ", ", "," | split: "," -%}
    {%- for line in lines -%}
    {{ line | replace: "|", "\|" }}
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
      </td>
    </tr>
    {%- endif %}

    {%- if entry['Webseite'] %}
    <tr>
      <td>{{ site.icons.globe }}</td>
      <td>
    {%- assign websites = entry['Webseite'] | strip | replace: ", ", "," | split: "," -%}
    {%- for website in websites -%}
    <a href="{{ website }}" target="_blank">{{ website }}</a>
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
      </td>
    </tr>
    {%- endif %}

    {%- if entry['Telegram'] %}
    <tr>
      <td>{{ site.icons.telegram }}</td>
      <td>
    {%- assign chanels = entry['Telegram'] | strip | replace: ", ", "," | split: "," -%}
    {%- for chanel in chanels -%}
    <a href="https://t.me/{{ chanel }}" target="_blank">{{ chanel }}</a>
    {%- unless forloop.last == true -%}
    <br/>
    {%- endunless -%}
    {%- endfor -%}
      </td>
    </tr>
    {%- endif %}

    {%- if entry['Video'] -%}
    <tr>
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
        {%- endif %}
<td>{{ platform }}</td><td><a href="{{ videoparts[1] }}" target="_blank">{{ videoparts[1] }}</a></td>
      {%- endfor %}
      </tr>
    {%- endif -%}
  </tbody>
</table>

  {% endfor %}

{% endfor %}
