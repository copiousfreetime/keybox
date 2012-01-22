module Keybox
    APP_ROOT_DIR        = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR         = File.join(APP_ROOT_DIR,"lib").freeze
    APP_RESOURCE_DIR    = File.join(APP_ROOT_DIR,"resources").freeze
    APP_VENDOR_DIR      = File.join(APP_ROOT_DIR,"vendor").freeze
    APP_BIN_DIR         = File.join(APP_ROOT_DIR,"bin").freeze

    # Ruby 1.9 compatibility fix for string encoding when reading/writing:
    def self.fix_encoding(*strings)
      strings.each do |string|
        string.force_encoding "binary" if string.respond_to?(:force_encoding)
      end
    end
end

$: << Keybox::APP_LIB_DIR

require 'keybox/version'
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

# Explicitly set the ruby YAML engine to syck for 1.9 compatibility. As of ruby
# 1.9.3, the default psych engine chokes on the binary strings keybox generates.
# This is fixed in ruby 1.9.3-head.
if YAML.const_defined?(:ENGINE)
  YAML::ENGINE.yamler = 'syck'
end
