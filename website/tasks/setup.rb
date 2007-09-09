
$: << "../lib"
require 'ostruct'
require 'keybox'
    
SITE = OpenStruct.new

SITE.content_dir   = 'content'
SITE.output_dir    = 'output'
SITE.layout_dir    = 'layousts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn]
SITE.deploy_to     = Keybox::SPEC.remote_site_location
SITE.news_file     = 'data/news.yaml'
  
SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

FileList['tasks/*.rake'].each {|task| import task}

# EOF
