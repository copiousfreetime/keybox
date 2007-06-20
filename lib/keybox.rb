module Keybox
    APP_ROOT_DIR    = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR     = File.join(APP_ROOT_DIR,"lib").freeze
    APP_DATA_DIR    = File.join(APP_ROOT_DIR,"data").freeze
    APP_VENDOR_DIR  = File.join(APP_ROOT_DIR,"vendor").freeze
    
    VERSION     = [1,1,1].freeze
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

require 'keybox/cipher'
require 'keybox/digest'
require 'keybox/entry'
require 'keybox/error'
require 'keybox/password_hash'
require 'keybox/randomizer'
require 'keybox/storage'
require 'keybox/string_generator'
require 'keybox/uuid'
require 'keybox/convert'
