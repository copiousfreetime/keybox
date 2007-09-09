
require 'ostruct'

SITE = OpenStruct.new

SITE.content_dir   = 'content'
SITE.output_dir    = 'output'
SITE.layout_dir    = 'layouts'
SITE.template_dir  = 'templates'
SITE.exclude       = %w[tmp$ bak$ ~$ CVS \.svn]
SITE.deploy_to     = "user@invalid.domain:/path/to/html"
  
SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

FileList['tasks/*.rake'].each {|task| import task}

# EOF
