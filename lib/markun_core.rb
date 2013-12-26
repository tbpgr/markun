# encoding: utf-8
require 'markun_dsl'
require 'erb'
require 'kramdown'
require 'pathname'

module Markun
  #  Markun Core
  class Core
    MARKUN_FILE = 'Markunfile'
    MARKUN_TEMPLATE = <<-EOS
# encoding: utf-8

# have menu or not
# have_menu allow only String
# have_menu's default value => "false"
have_menu "false"

    EOS

    HTML_TEMPLATE = <<-EOS
<!doctype html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title><%=title%></title>
  <link href="markdown.css" rel="stylesheet" />
</head>
<body>
<%=menu%>
<%=contents%>
</body>
</html>
    EOS

    # == generate Markunfile to current directory.
    def init
      File.open(MARKUN_FILE, 'w') { |f|f.puts MARKUN_TEMPLATE }
    end

    # == execute markdown convert
    def execute
      src = read_dsl
      dsl = Markun::Dsl.new
      dsl.instance_eval src
      convert_markdown_to_html dsl.markun.have_menu
    end

    private

    def read_dsl
      File.open(MARKUN_FILE) { |f|f.read }
    end

    def convert_markdown_to_html(have_menu)
      Dir.glob('**/*.md').each do |file|
        md = File.read(file)
        contents = Kramdown::Document.new(md.force_encoding('utf-8')).to_html
        menu = get_menu(file, have_menu)
        html = get_html_template(File.basename(file, '.md'), contents, menu)
        html_file_name = file.gsub('.md', '.html')
        File.open(html_file_name, 'w:utf-8') { |f|f.puts html.encode('utf-8') }
      end
    end

    def get_menu(file, have_menu)
      return '' unless have_menu == 'true'
      absolute_path = File.dirname(File.absolute_path(file))
      base = Pathname.new(absolute_path)
      create_menu base
    end

    def get_html_template(title, contents, menu)
      erb = ERB.new(HTML_TEMPLATE)
      erb.result(binding)
    end

    def create_menu(base)
      urls = get_urls([])
      urls_to_menu(urls, base)
    end

    def get_urls(urls)
      urls += get_each_urls
      Dir.glob('*/') do |d|
        Dir.chdir(d)
        urls = get_urls(urls)
        Dir.chdir('../')
      end
      urls
    end

    def get_each_urls
      Dir.glob('./*.md').map { |f|File.absolute_path(f) }
    end

    def urls_to_menu(urls, base)
      ret = []
      urls.each do |f|
        _filename = Pathname.new(f.gsub('md', 'html')).relative_path_from(base)
        ret << "<a href='#{_filename}'>#{_filename}</a><br />"
      end
      ret.join('') + '<hr />'
    end
  end
end
