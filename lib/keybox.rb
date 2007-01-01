module Keybox
    APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib").freeze
    APP_RESOURCE_DIR = File.join(APP_ROOT_DIR,"resource").freeze
    
    VERSION     = [1,0,0].freeze
    AUTHOR      = "Jeremy Hinegardner".freeze
    AUTHOR_EMAIL= "jeremy@hinegardner.org".freeze
    HOMEPAGE    = "http://keybox.rubyforge.org".freeze
    COPYRIGHT   = "2006, 2007 #{AUTHOR}".freeze
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
require 'keybox/term_io'
require 'keybox/convert'
