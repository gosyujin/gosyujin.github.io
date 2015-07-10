# -*- coding: utf-8 -*-

# {% tree %} 記載箇所に
# ページの見出しを集めた目次を出力する。
# a タグを使ったページ内リンクは
# kramdown-0.14.2 の仕様を元に生成
module Jekyll
  class TreeListTag < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    H1_SHARP_COUNT = 1

    def render(context)
      # exclude .htn file
      return if File.extname(context.environments[0]["page"]["path"]) == ".htn"

      tree =  '<div class="content_tree_wrapper">'
      tree <<  '<h2 class="content_tree">目次</h2>'
      tree << '<div class="content_tree_list">'
      tree << '<ul><!-- start tree list -->'

      current_sharp_count = H1_SHARP_COUNT + 1
      before_sharp_count  = H1_SHARP_COUNT + 1
      # count section: section-1, section-2 ...
      total_sharp_count   = 0

      # is ignore area?
      ignore = false

      content = context.environments[0]["page"]["content"]
      content.each_line do |line|
        unless ignore_area?(line, ignore) then
          ignore = false

          if line =~ /^#+[ ]/ then
            # $`:マッチした前 $&:マッチした箇所 $':マッチした後
            current_sharp_count = $&.count("#")
            title               = $'.chomp
            # puts "Tree: bef:#{before_sharp_count}, #{("#" * current_sharp_count)} #{title}"

            # #### sample 1-1-1
            # ## sample 2
            while current_sharp_count < before_sharp_count do
              tree << '</ul>'
              before_sharp_count -= 1
            end
            # ## sample 1
            # ### sample 1-1
            while current_sharp_count > before_sharp_count do
              tree << '<ul>'
              before_sharp_count += 1
            end

            # titleに影響しないように深いコピー
            title_link = Marshal.load(Marshal.dump(title))

            # redcarpetでは空白、ドットはハイフン、アルファベットはすべて小文字に変換される
            # xx(yy)はxx-yyだが、xx(yy)zzはxx-yy-zz
            # はじめに行末の閉じカッコを消す
            title_link.gsub!(/\)$/, "")
            # スラッシュも消える
            title_link.gsub!(/\//, "")

            # 残りはハイフンに
            title_link.gsub!(/ /, "-")
            title_link.gsub!(/:/, "-")
            title_link.gsub!(/\)/, "-")
            title_link.gsub!(/\(/, "-")
            title_link.gsub!(/\./, "-")
            # ハイフンが続く場合は一つに
            title_link.gsub!(/-+/, "-")
            tree << "<li><a href='##{title_link.downcase}'>#{title}</a></li>"

            total_sharp_count += 1
            before_sharp_count = current_sharp_count
          end
        else
          ignore = true
        end
      end
      while current_sharp_count > H1_SHARP_COUNT do
        tree << "</ul>"
        current_sharp_count -= 1
      end

      tree << '</ul><!-- end of tree list -->'
      tree << '</div>'
      tree << '</div>'
    end

private
    # ignore area (ex. in source code by pygments)
    def ignore_area?(line, ignore)
      if line =~ /^{% highlight / then
        # puts "switch ignore    : #{line}"
        true
      elsif line =~ /^{% endhighlight / then
        # puts "switch not ignore: #{line}"
        false
      else
        # puts "keep          #{ignore ? "ign" : "not"}: #{line}"
        ignore
      end
    end
  end
end

Liquid::Template.register_tag('tree', Jekyll::TreeListTag)
