---
layout: page
title: Tags
---

## Tag cloud

<div class="tag_box inline">
{% assign sorted_tags = site.tags | sort %}
{% for tag in sorted_tags %}
  {% assign t = tag[0] %}
  <code><a href="/tags.html#{{ t }}">{{ t }} <sub>{{ site.tags[t].size }}</sub></a></code>
{% endfor %}
</div>

## Entries

{% assign sorted_tags = site.tags | sort %}
{% for tag in sorted_tags %}
  <h3 id="{{ tag[0] }}">{{ tag[0] }}</h3>

  {% assign lists = tag[1] %}
  {% include list.html %}

{% endfor %}
