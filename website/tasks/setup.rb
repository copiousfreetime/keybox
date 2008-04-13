
require 'keybox'

begin
  require 'webby'
rescue LoadError
  require 'rubygems'
  require 'webby'
end

SITE = Webby.site

SITE.output_dir    = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "doc"))
SITE.news_file     = 'data/news.yaml'

# Load the other rake files in the tasks folder
Dir.glob('tasks/*.rake').sort.each {|fn| import fn}

# EOF
