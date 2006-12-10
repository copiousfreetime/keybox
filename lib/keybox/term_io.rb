module Keybox
    # including this module assumes that the class included has 
    # @stdout and @stdin member variables.
    #
    # This module also assumes that stty is available
    module TermIO

        EOL_CHARS = [10, # '\n'
                     13, # '\r'
        ]
        #
        # prompt for input, returning what was typed.  If echo is false,
        # then '*' is printed out for each character typed in.  If it is
        # any other character then that is output instead.
        #
        def prompt(p,echo = true) 
            @stdout.print("#{p} ")
            line = ""

            if echo != true then

                echo_char = echo || '*'

                if has_stty? then
                    stty_original = %x{stty -g}

                    begin
                        system "stty raw -echo cbreak"
                        while char = @stdin.getc
                            break if EOL_CHARS.include? char
                            line << char
                            @stdout.putc echo_char
                        end
                    ensure
                        system "stty #{stty_original}"
                    end
                end
            else
                line = @stdin.gets
            end
            @stdout.puts
            return line.rstrip
        end

        def has_stty?
            system "which stty > /dev/null 2>&1"
        end
    end
end
