require 'uri'
require 'digest/sha1'
module Keybox

  # this is an implementation of the password hash algorithm used at 
  # http://www.xs4all.nl/~jlpoutre/BoT/Javascript/PasswordComposer/
  #
  # This implementation uses the SHA1 hash instead of the MD5
  #
  # This class uses a master password and with that information
  # generates a unique password for all subsequent strings passed to
  # it.
  #
  class PasswordHash

    attr_writer :master_password

    def initialize(master_password = "")
      @master_password = master_password
      @digest_class    = ::Digest::SHA1
    end

    def password_for_url(url)
      uri = URI.parse(url)
      password_for(uri.host)
    end

    def password_for(str)
      @digest_class.hexdigest("#{@master_password}:#{str}")[0..8]
    end
  end
end
