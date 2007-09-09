
require 'ostruct'

SITE = OpenStruct.new

SITE.content_dir   = 'content'
# TODO: change this to the value from the SPEC
SITE.output_dir    = File.join(File.dirname(__FILE__),"..","..","doc")
SITE.layout_dir    = 'layouts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn]
# TODO: change this to the value from the SPEC
SITE.deploy_to     = "jjh@rubyforge.org:/path/to/html"
SITE.news_file     = "data/news.yaml"
  
SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

FileList['tasks/*.rake'].each {|task| import task}

# EOF
