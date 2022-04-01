---
layout:   page
title:    Infos
subtitle: IT
permalink: /infos/it
---

## Inhalt
{: .no_toc}

* TOC
{:toc}

{% assign entries = site.data.it | group_by: "Typ"  | sort: "name" %}
{% if entries.size > 0 %}
{% include info-list.md entries=entries %}
{% endif %}

