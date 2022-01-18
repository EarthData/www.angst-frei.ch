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

## Schweiz

{% assign entries = site.data.allgemein | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}

{% include info-list.md entries=entries %}

## International

{% assign world_entries = site.data.allgemein | where_exp: "item", "item.Land != 'Schweiz'" | group_by: "Typ"  | sort: "name" %}

{% include info-list.md entries=world_entries %}
