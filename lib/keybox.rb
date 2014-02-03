module Keybox
  VERSION             = "1.4.0"

  # Some untility directories for introspection
  APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,"..")))
  APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib")
  APP_RESOURCE_DIR = File.join(APP_ROOT_DIR,"resources")

end

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
