require 'stringio'
def sitemap
  content = StringIO.new
  content.puts '<ul class="sidemenu">'
  site_pages = @pages.find( :limit => :all ) { |r| not r.sitemap_order.nil? }
  site_pages.sort_by { |p| p.sitemap_order }.each do |p|
    class_attr = ''
    before_tag = "<a href=\"#{p.filename}.#{p.extension}\">"
    after_tag  = "</a>"

    if @page == p then    
      class_attr = ' class="menu-selected" '
      before_tag = "<span>"
      after_tag  = "</span>"
    end

    content.puts "<li#{class_attr}>#{before_tag}#{p.title}#{after_tag}</li>"

  end
  content.puts "</ul>"
  return content.string
end

# include a file from the content_dir into the output
# 
def include(file, options = {})
  content = StringIO.new
  content.puts "<notextile>" if options[:skip_textile]
  content.puts IO.read(File.join(::Webby.site.content_dir, file))
  content.puts "</notextile>" if options[:skip_textile]
  content.string
end
