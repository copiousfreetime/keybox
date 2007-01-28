module Keybox
    APP_ROOT_DIR    = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR     = File.join(APP_ROOT_DIR,"lib").freeze
    APP_DATA_DIR    = File.join(APP_ROOT_DIR,"data").freeze
    
    VERSION     = [1,1,0].freeze
    AUTHOR      = "Jeremy Hinegardner".freeze
    AUTHOR_EMAIL= "jeremy@hinegardner.org".freeze
    HOMEPAGE    = "http://keybox.rubyforge.org".freeze
    COPYRIGHT   = "2006, 2007 #{AUTHOR}".freeze
    DESCRIPTION = <<DESC
Keybox is a set of command line applications and ruby libraries for
secure password storage and password generation. 
DESC
end

$: << Keybox::APP_LIB_DIR

# highline can be required via the new gem method or it can use the
# version of highline shipped with keybox.
require 'rubygems'
gem 'highline', ">= 1.2.6"
require 'highline'

require 'keybox/cipher'
require 'keybox/digest'
require 'keybox/entry'
require 'keybox/error'
require 'keybox/password_hash'
require 'keybox/randomizer'
require 'keybox/storage'
require 'keybox/string_generator'
require 'keybox/uuid'
require 'keybox/highline_util'
require 'keybox/convert'
