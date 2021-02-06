---
layout:        page
title:         News Archive
cover-img:     /assets/img/news_archive.jpg
ext-css:       ["//cdn.jsdelivr.net/cal-heatmap/3.3.10/cal-heatmap.css"]
js:            ["/assets/scripts/moment.min.js", "/assets/js/heatmap.js", "/assets/js/isotope.js"]
ext-js:        ["//d3js.org/d3.v3.min.js", "//cdn.jsdelivr.net/cal-heatmap/3.3.10/cal-heatmap.min.js", "https://unpkg.com/isotope-layout@3/dist/isotope.pkgd.min.js"]
---

{% assign date_format = site.date_format | default: "%B %-d, %Y" %}

<div id="calendar" style="margin:0 auto;">
  <div id="cal-heatmap"></div>
  <div style="padding-top: 10px;">
    <a href="#" style="margin-right:10px;" id="cal-heatmap-PreviousDomain-selector"><i class="fa fa-chevron-left"></i></a>
    <a href="#" style="float:right;" id="cal-heatmap-NextDomain-selector"><i class="fa fa-chevron-right"></i></a>
  </div>
</div>

<br/>

<div class="grid">
  {% for post in site.posts %}
  <div class="element-item {{ post.date }}">
    <article class="post-preview">

    {%- capture thumbnail -%}
      {% if post.thumbnail-img %}
        {{ post.thumbnail-img }}
      {% elsif post.cover-img %}
        {% if post.cover-img.first %}
          {{ post.cover-img[0].first.first }}
        {% else %}
          {{ post.cover-img }}
        {% endif %}
      {% else %}
      {% endif %}
    {% endcapture %}
    {% assign thumbnail=thumbnail | strip %}

    {% if site.feed_show_excerpt == false %}
    {% if thumbnail != "" %}
    <div class="post-image post-image-normal">
      <a href="{{ post.url | absolute_url }}" aria-label="Thumbnail">
        <img src="{{ thumbnail | absolute_url }}" alt="Post thumbnail">
      </a>
    </div>
    {% endif %}
    {% endif %}

    {%- if post.redirect -%}
    <a href="{{ post.redirect | absolute_url }}">
    {% else %}
    <a href="{{ post.url | absolute_url }}">
    {% endif %}

      <h2 class="post-title">{{ post.title }}</h2>

      {% if post.subtitle %}
        <h3 class="post-subtitle">
        {{ post.subtitle }}
        </h3>
      {% endif %}
    </a>

    <p class="post-meta">
      {% assign date_format = site.date_format | default: "%B %-d, %Y" %}
      Posted on {{ post.date | date: date_format }}
    </p>

    {% if thumbnail != "" %}
    <div class="post-image post-image-small">
      <a href="{{ post.url | absolute_url }}" aria-label="Thumbnail">
        <img src="{{ thumbnail | absolute_url }}" alt="Post thumbnail">
      </a>
    </div>
    {% endif %}

    {% if site.feed_show_persons != false and post.persons.size > 0 %}
    <div class="blog-tags">
      <span>Personen:</span>
      {% for person in post.persons %}
      <a href="{{ '/persons' | absolute_url }}#{{- person -}}">{{- person -}}</a>
      {% endfor %}
    </div>
    {% endif %}

    {% if site.feed_show_categories != false and post.categories.size > 0 %}
    <div class="blog-tags">
      <span>Kategorien:</span>
      {% for category in post.categories %}
      <a href="{{ '/categories' | absolute_url }}#{{- category -}}">{{- category -}}</a>
      {% endfor %}
    </div>
    {% endif %}

    {% if site.feed_show_tags != false and post.tags.size > 0 %}
    <div class="blog-tags">
      <span>Tags:</span>
      {% for tag in post.tags %}
      <a href="{{ '/tags' | absolute_url }}#{{- tag -}}">{{- tag -}}</a>
      {% endfor %}
    </div>
    {% endif %}

   </article>

  </div>
  {% endfor %}
</div>

<br/>

<script>

var data = {% assign counter = 0 %}{
{% for post in site.posts %}{% capture day %}{{ post.date | date: '%s' }}{% endcapture %}{% capture prevday %}{{ post.previous.date | date: '%s' }}{% endcapture %}{% assign counter = counter | plus: 1 %}{% if day != prevday %}"{{ post.date | date: '%s' }}": {{ counter }}{% assign counter = 0 %}{% if forloop.last == false %},{% endif %}
{% endif %}{% endfor %}};

</script>

