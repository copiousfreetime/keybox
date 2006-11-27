
module Keybox
    APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib").freeze
    APP_RESOURCE_DIR = File.join(APP_ROOT_DIR,"resource").freeze
    
    VERSION     = [1,0,0].freeze
    AUTHOR      = "Jeremy Hinegardner".freeze
    COPYRIGHT   = "2006, Jeremy Hinegardner".freeze
    DESCRIPTION = <<DESC
kpg is a pure ruby implementation of the 'apg' program. It attempts
to implement all the functionality of 'apg', but it is not completely
compatible.

apg (Automated Password Generator) was originally developed by
Adel I. Mirzazhanov and can be found at http://www.adel.nursat.kz/apg/
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
