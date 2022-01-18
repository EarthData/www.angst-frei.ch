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

## Schweiz

{% assign entries = site.data.recht | where: "Land", "Schweiz" | group_by: "Typ"  | sort: "name" %}

{% include info-list.md entries=entries %}

## International

{% assign world_entries = site.data.recht | where_exp: "item", "item.Land != 'Schweiz'" | group_by: "Typ"  | sort: "name" %}

{% include info-list.md entries=world_entries %}

