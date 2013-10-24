# -*- coding: utf-8 -*-

module Jekyll
  # use Reference and ReferenceAnchor
  $reference = {}

  class Reference < Liquid::Tag
    # reference counter
    @@ref_num = 1

    def initialize(tag_name, name, tokens)
      super
      @reference = name
    end

    def render(context)
      unless context.environments[0].key?("reference_anchor") then
        @@ref_num = 1
        context.environments[0]["reference_anchor"] = {}
      end

      page_id = context.environments[0]["page"]["id"].gsub('/', '')
      link = "reference-anchor-#{page_id}-#{@@ref_num}"
      anchor = "<a href='##{link}' name='#{link}ori' title='#{@reference}'>*#{@@ref_num}</a>"

      $reference[@@ref_num] = @reference

      @@ref_num += 1
      anchor
    end
  end

  class ReferenceAnchor < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    def render(context)
      return if $reference.none?

      list = "<hr class='start-reference'><div class='reference'><ul>"
      page_id = context.environments[0]["page"]["id"].gsub('/', '')
      $reference.each do |ref_num, reference|
        link = "reference-anchor-#{page_id}-#{ref_num}"
        list << "<li>"
        list << "<a href='##{link}ori' name='#{link}' title='#{reference}'>*#{ref_num}</a>"
        list << "<span> #{reference}</span>"
        list << "</li>"
      end
      list << "</ul></div>"

      # RESET global $reference BEFORE return list
      $reference = {}

      list
    end
  end
end

Liquid::Template.register_tag('ref', Jekyll::Reference)
Liquid::Template.register_tag('ref_anchor', Jekyll::ReferenceAnchor)
