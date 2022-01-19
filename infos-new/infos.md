---
layout:   page
title:    Infos
subtitle: Allgemein
permalink: /infos/allgemein
---

## Inhalt
{: .no_toc}

* TOC
{:toc}

{% assign entries = site.data.allgemein | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}
{% if entries.size > 0 %}
## Schweiz
{% include info-list.md entries=entries %}
{% endif %}

{% assign entries = site.data.allgemein | where_exp: "item", "item.Land != 'Schweiz'" | group_by: "Typ"  | sort: "name" %}
{% if entries.size > 0 %}
## International
{% include info-list.md entries=entries %}
{% endif %}
