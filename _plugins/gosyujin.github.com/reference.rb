# -*- coding: utf-8 -*-

module Jekyll
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

      page_id = context.environments[0]["page"]["id"]
      link = "reference-anchor-#{page_id}-#{@@ref_num}"
      anchor = "<a href='##{link}' name='#{link}ori' title='#{@reference}'>*#{@@ref_num}</a>"

      context.environments[0]["reference_anchor"][@@ref_num] = @reference

      @@ref_num += 1
      anchor
    end
  end

  class ReferenceAnchor < Liquid::Tag
    def initialize(tag_name, name, tokens)
      super
    end

    def render(context)
      return unless context.environments[0].key?("reference_anchor")

      list = "<hr class='start-reference'><div class='reference'><ul>"
      page_id = context.environments[0]["page"]["id"]

      context.environments[0]["reference_anchor"].each do |ref_num, reference|
        link = "reference-anchor-#{page_id}-#{ref_num}"
        list << "<li><a href='##{link}ori' name='#{link}'>*#{ref_num}</a> #{reference}</li>"
      end
      list << "</ul></div>"
    end
  end
end

Liquid::Template.register_tag('ref', Jekyll::Reference)
Liquid::Template.register_tag('ref_anchor', Jekyll::ReferenceAnchor)
