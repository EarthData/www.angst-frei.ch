---
layout:   page
title:    Infos
subtitle: Recht
permalink: /infos/recht
---

## Inhalt
{: .no_toc}

* TOC
{:toc}

{% assign entries = site.data.recht | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}
{% if entries.size > 0 %}
## Schweiz
{% include info-list.md entries=entries %}
{% endif %}

{% assign entries = site.data.recht | where_exp: "item", "item.Land != 'Schweiz'" | group_by: "Typ"  | sort: "name" %}
{% if entries.size > 0 %}
## International
{% include info-list.md entries=entries %}
{% endif %}
