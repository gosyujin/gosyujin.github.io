---
layout: page
title: kk_Atakaの日記 index
tagline: ""
---
{% include JB/setup %}

## Recent Entries

<ul class="posts">
  {% for post in site.posts %}
    <li>
      <span>{{ post.date | date_to_string }}</span>
      &raquo;
      <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
