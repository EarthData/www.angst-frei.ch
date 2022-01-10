---
layout:   page
title:    Recht
subtitle: Schweiz
---

{% assign entries = site.data.recht | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}

{% for group in entries %}

## {{ group.name }}

  {% for entry in group.items | sort: "Name" %}

### {{ entry['Name'] }}

    {% if entry['Beschreibung'] %}
{{ entry['Beschreibung'] }}
    {% endif %}

    {% if entry['Webseite'] %}
| {{ site.icons.globe }}    | [{{entry['Webseite']}}]({{entry['Webseite']}}) |
    {% endif %}

    {%- if entry['Telegram'] -%}
| {{ site.icons.telegram }} | [{{entry['Telegram']}}]({{entry['Telegram']}}) |
    {% endif %}

  {% endfor %}

{% endfor %}

