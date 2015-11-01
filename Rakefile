require "rubygems"
require 'rake'
require 'yaml'
require 'time'

SOURCE = "."
CONFIG = {
  'posts' => File.join(SOURCE, "_posts"),
  'post_ext' => "md",
}

# Usage: rake deploy
desc "Begin a push static file to GitHub"
task :deploy do
  # push
  sh "git push origin source:source"

  # convert
  sh "rm -rf _site/*"
  sh "jekyll build"
  sh "ruby _scripts/convert_html_to_hatena.rb"
end

desc "Begin CircleCI"
task :circle do
  sh "jekyll build"
  sh "ls _site"
  sh "git clone -b master git@github.com:gosyujin/gosyujin.github.io.git ~/gh-pages"
  sh "ls ~/gh-pages"
#  sh "rm -rf ~/gh-pages/*"
#  sh "cp -R _site/* ~/gh-pages"
  sh "cp -R circle.yml.gh-pages ~/gh-pages/circle.yml"

  sh "cd ~/gh-pages ; git branch"

  sh "git branch"
  sh "git checkout master"
  sh "git add -A"
  sh "git status -s > /tmp/gitstatus"
  sh "ls -l /tmp/gitstatus"
  sh "cat /tmp/gitstatus"
  sh "git commit -m 'Commit at CircleCI'"
  sh "git push origin master"
end

# Usage: rake post title="A Title" [date="2012-02-09"]
desc "Begin a new post in #{CONFIG['posts']}"
task :post do
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])
  title = ENV["title"] || "new-post"
  slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  begin
    date = (ENV['date'] ? Time.parse(ENV['date']) : Time.now).strftime('%Y-%m-%d')
  rescue Exception => e
    puts "Error - date format must be YYYY-MM-DD, please check you typed it correctly!"
    exit -1
  end
  filename = File.join(CONFIG['posts'], "#{date}-#{slug}.#{CONFIG['post_ext']}")
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/-/,' ')}\""
    post.puts 'description: ""'
    post.puts "category: "
    post.puts "tags: []"
    post.puts "---"
    post.puts ""
  end
end # task :post

# Usage: rake page name="about.html"
# You can also specify a sub-directory path.
# If you don't specify a file extention we create an index.html at the path specified
desc "Create a new page."
task :page do
  name = ENV["name"] || "new-page.md"
  filename = File.join(SOURCE, "#{name}")
  filename = File.join(filename, "index.html") if File.extname(filename) == ""
  title = File.basename(filename, File.extname(filename)).gsub(/[\W\_]/, " ").gsub(/\b\w/){$&.upcase}
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  
  mkdir_p File.dirname(filename)
  puts "Creating new page: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: page"
    post.puts "title: \"#{title}\""
    post.puts "---"
    post.puts ""
  end
end # task :page
