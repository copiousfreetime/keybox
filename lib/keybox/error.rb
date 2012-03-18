module Keybox
  class KeyboxError      < ::StandardError ; end
  class ValidationError  < KeyboxError; end
  class ApplicationError < KeyboxError; end
end
