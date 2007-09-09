module Keybox
    APP_ROOT_DIR        = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR         = File.join(APP_ROOT_DIR,"lib").freeze
    APP_RESOURCE_DIR    = File.join(APP_ROOT_DIR,"resources").freeze
    APP_VENDOR_DIR      = File.join(APP_ROOT_DIR,"vendor").freeze
    APP_BIN_DIR         = File.join(APP_ROOT_DIR,"bin").freeze
end

$: << Keybox::APP_LIB_DIR

require 'keybox/version'
require 'keybox/specification'
require 'keybox/gemspec'
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
