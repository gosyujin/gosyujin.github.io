# -*- coding: utf-8 -*-

# page ファイルの拡張子が .htn の場合
# {% old_hatena %} 記載箇所に 旧はてなダイアリーへのリンクを貼る
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
        hatena << '<p>うまく表示されない場合ははてなダイアリーで見てみてください。</p>'
        hatena << "<p> => <a href='#{url}'>#{title}</a></p>"
        hatena
      end
    end
  end
end

Liquid::Template.register_tag('old_hatena', Jekyll::OldHatenaLink)
