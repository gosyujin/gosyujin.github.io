# -*- coding: utf-8 -*-
# h1 x
# link x

module Jekyll
  class TreeListTag < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    def render(context)
      tree = '<h2>Contents</h2><div class="tree_list"><ul>'

      h1 = 1
      now_hx = h1 + 1
      before_hx = h1 + 1
      ignore_area = false

      content = context.environments[0]["page"]["content"]
      content.each_line do |line|
        if line =~ /^{% endhighlight / then
          ignore_area = false
        elsif line =~ /^{% highlight / then
          ignore_area = true
        end

        if !ignore_area then
          if line =~ /^#+[ ]/ then
            # $`:マッチした前 $&:マッチした箇所 $':マッチした後
            now_hx = $&.count("#")
            title = $'
            # puts "Tree sharp.count:#{now_hx}, bef:#{before_hx}, title:#{title}"

            while now_hx < before_hx do
              tree += "</ul>"
              before_hx -= 1
            end
            while now_hx > before_hx do
              tree += "<ul>"
              before_hx += 1
            end
            tree += "<li>#{title.chomp!}</li>"

            before_hx = now_hx
          end
        end
      end
      while now_hx > h1 do
        tree += "</ul>"
        now_hx -= 1
      end

      tree += "</ul></div>"
    end
  end
end

Liquid::Template.register_tag('tree', Jekyll::TreeListTag)
