require 'nokogiri'
require 'time'

ABSOLUTE_IMG_PATH = "http://gosyujin.github.com/images"

# permalink: yyyy/mm/dd
arg = ARGV[0]
begin
  # no ARGV: now
  if ARGV.length == 0 then
    arg = Time.now.to_s
  end
  permalink = Time.parse(arg).strftime('%Y/%m/%d')
rescue => ex
  arg = Time.now.to_s
  retry
end

scripts   = File.expand_path(File.dirname(__FILE__))
site      = "#{scripts}/../_site"
path      = "#{site}/#{permalink}/**/index.html"

files = Dir.glob(path)
if files == [] then
  puts "_site index files is"
  puts Dir.glob("#{site}/**/index.html")
  puts "-----------------------"
  puts "#{path}: file not found"
  exit 0
end

files.each do |file|
  File.open(file, "r") do |f|
    doc = Nokogiri::HTML(f.read)

    # hatena first line
    # ex: *[Java][Android]title hogehoge
    title = "*"

    # get blog tags
    # ex: <a href="/tags.html#Java-ref">Java <span>11</span></a>
    doc.xpath('//ul[@class="tag_box"]/li/a').each do |tags|
      title << "[#{tags.text.split(' ')[0]}]"
    end

    # get blog title
    # ex: <h1>blog title hogehoge </h1>
    doc.xpath('//h1').each do |h1|
      title << h1.text
    end

    # hatena content
    content = ""
    doc.xpath('//div[@class="span8"]').each do |con|
      # remove pagination
      con.children.xpath('//div[@class="pagination"]').remove
      # remove disqus script
      con.children.xpath('//div[@id="disqus_thread"]').remove
      con.children.xpath('//script').remove
      con.children.xpath('//noscript').remove
      con.children.xpath('//a[@class="dsq-brlink"]').remove

      content << con.children.to_s
    end

    # output
    puts title

    content.each_line do |content_line|
      if content_line.match(/<\/?h([1-9])/) then
        # headline conbine hatena format
        # jekyll: ## (h2) == hatena: <h4>
        headline = $1.to_i
        puts content_line.gsub(/(<\/?)h#{headline}/, '\1h%i' % [headline + 2])
      elsif content_line.match(/<img src="\/images/) then
        # img src convert absolute path to github
        puts content_line.gsub(/<img src="\/images/, "<img src=\"#{ABSOLUTE_IMG_PATH}")
      else
        puts content_line
      end
    end
  end
end
