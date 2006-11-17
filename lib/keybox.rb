
module Keybox
    APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,"..")))
    APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib")
    APP_RESOURCE_DIR = File.join(APP_ROOT_DIR,"resource")
    
    VERSION     = "1.0.0"
    AUTHOR      = "Jeremy Hinegardner"
    COPYRIGHT   = "2006, Jeremy Hinegardner"
end

$: << Keybox::APP_LIB_DIR

require 'keybox/randomizer'
require 'keybox/string_generator'
require 'keybox/password_hash'
require 'keybox/database'
