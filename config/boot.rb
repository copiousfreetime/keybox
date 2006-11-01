# bootstrap configuration
module Keybox
    APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,"..")))
    APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib")
    APP_RESOURCE_DIR = File.join(APP_ROOT_DIR,"resource")
end

$: << Keybox::APP_LIB_DIR

