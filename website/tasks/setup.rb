
$: << "../lib"
require 'ostruct'
require 'keybox'
    
SITE = OpenStruct.new

SITE.content_dir   = 'content'
SITE.output_dir    = File.join(Keybox::APP_ROOT_DIR,Keybox::SPEC.local_site_dir)
SITE.layout_dir    = 'layouts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn]
SITE.news_file     = 'data/news.yaml'
  
SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

FileList['tasks/*.rake'].each {|task| import task}

# EOF
