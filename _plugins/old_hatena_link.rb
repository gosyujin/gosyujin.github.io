# -*- coding: utf-8 -*-

module Jekyll
  class OldHatenaLink < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    def render(context)
      if File.extname(context.environments[0]["page"]["path"]) == ".htn" then
        title = context.environments[0]["page"]["title"]
        url   = context.environments[0]["page"]["old_url"]

        hatena =  '<h2 class="old_hatena_url">注意</h2>'
        hatena << '<p>うまく表示されない場合ははてなダイアリーで見てください。</p>'
        hatena << "<a href='#{url}'>#{title}</a>"
        hatena
      end
    end
  end
end

Liquid::Template.register_tag('old_hatena', Jekyll::OldHatenaLink)
