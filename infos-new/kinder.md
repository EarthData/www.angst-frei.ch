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

## Schweiz

{% include info-list.md entries=entries %}

{% assign entries = site.data.kinder | where_exp: "item", "item.Land != 'Schweiz'" | group_by: "Typ"  | sort: "name" %}

## International

{% include info-list.md entries=entries %}
