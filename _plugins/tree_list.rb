# -*- coding: utf-8 -*-

module Jekyll
  class TreeListTag < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    H1_SHARP_COUNT = 1

    def render(context)
      # exclude .htn file
      return if File.extname(context.environments[0]["page"]["path"]) == ".htn"

      tree =  '<h2 class="content_tree">Contents</h2>'
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
            title               = $'
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

            tree << "<li><a href='##{generate_id(title)}'>#{title.chomp!}</a></li>"

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
    end

private

    # COPY from kramdown-0.14.2/lib/kramdown/converter/base#generate_id
    def generate_id(str)
      gen_id = str.gsub(/^[^a-zA-Z]+/, '')
      gen_id.tr!('^a-zA-Z0-9 -', '')
      gen_id.tr!(' ', '-')
      gen_id.downcase!
      gen_id = 'section' if gen_id.length == 0
      @used_ids ||= {}
      if @used_ids.has_key?(gen_id)
        gen_id += '-' << (@used_ids[gen_id] += 1).to_s
      else
        @used_ids[gen_id] = 0
      end
      gen_id
    end

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
