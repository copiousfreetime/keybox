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
        # If validate is set to true, then it will prompt twice and make
        # sure that the two values match
        #
        def prompt(p,echo = true, validate = false) 
            validated = false
            line = ""
            original_prompt = p
            validation_prompt = original_prompt + " (again to validate)"

            until validated do
                line = prompt_and_return(original_prompt,echo)

                # if we are validating then prompt again to validate
                if validate then
                    v = prompt_and_return(validation_prompt,echo)
                    if v != line then
                        @stdout.puts("Entries do not match, try again.")
                    else
                        validated = true
                    end
                else 
                    validated = true
                end
            end
            return line
        end

        def prompt_and_return(the_prompt,echo)
            line = ""
            @stdout.print("#{the_prompt} ")
            if echo != true then

                echo_char = echo || '*'

                if has_stty? then
                    stty_original = %x{stty -g}

                    begin
                        system "stty raw -echo cbreak"
                        while char = @stdin.getc
                            line << char
                            break if EOL_CHARS.include? char 
                            @stdout.putc echo_char
                        end
                    ensure
                        system "stty #{stty_original}"
                    end
                    @stdout.puts
                end
            else
                line = @stdin.gets
            end

            # if we got end of file or some other input resulting in
            # line becoming nil then set it to the empty string
            line = line || ""

            return line.rstrip
        end

        def has_stty?
            system "which stty > /dev/null 2>&1"
        end
    end
end
