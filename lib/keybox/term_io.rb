module Keybox
    # including this module assumes that the class included has 
    # @stdout and @stdin member variables.
    #
    # This module also assumes that stty is available
    module TermIO

        # http://pueblo.sourceforge.net/doc/manual/ansi_color_codes.html
        #
        ESCAPE      = "\e"
        BOLD_ON     = "[1m"
        RESET       = "[0m"

        FG_BLACK   = "[30m"
        FG_RED     = "[31m"
        FG_GREEN   = "[32m"
        FG_YELLOW  = "[33m"
        FG_BLUE    = "[34m"
        FG_MAGENTA = "[35m"
        FG_CYAN    = "[36m"
        FG_WHITE   = "[37m"

        COLORS = { 
            :black     => FG_BLACK,
            :red       => FG_RED,
            :green     => FG_GREEN,
            :yellow    => FG_YELLOW,
            :blue      => FG_BLUE,
            :magenta   => FG_MAGENTA,
            :cyan      => FG_CYAN,
            :white     => FG_WHITE,
            }   

        VALID_COLORS = COLORS.keys()


        STTY            = "stty"
        STTY_SAVE_CMD   = "#{STTY} -g"
        STTY_RAW_CMD    = "#{STTY} raw -echo isig"

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
        def prompt(p,echo = true, validate = false, width = 20) 
            validated = false
            line = ""
            extra_prompt = " (again)"
            original_prompt = p
            validation_prompt = original_prompt + extra_prompt
            width += extra_prompt.length

            until validated do
                line = prompt_and_return(original_prompt.rjust(width),echo)

                # if we are validating then prompt again to validate
                if validate then
                    v = prompt_and_return(validation_prompt.rjust(width),echo)
                    if v != line then
                        color_puts "Entries do not match, try again.", :error
                    else
                        validated = true
                    end
                else 
                    validated = true
                end
            end
            return line
        end

        def prompt_y_n(p)
            response = prompt(p)
            if response.size > 0 and response.downcase[0].chr == 'y' then
                true
            else
                false
            end
        end

        def get_one_char
            stty_original = %x{#{STTY_SAVE_CMD}}
            char = nil
            begin
                system STTY_RAW_CMD
                char = @stdin.getc
            ensure
                system "#{STTY} #{stty_original}"
            end

            return char
        end

        def prompt_and_return(the_prompt,echo)
            line = ""
            color_print "#{the_prompt} : ", :white
            if echo != true then

                echo_char = echo || '*'

                if has_stty? then
                    stty_original = %x{#{STTY_SAVE_CMD}}

                    begin
                        system STTY_RAW_CMD
                        while char = @stdin.getc
                            line << char
                            break if EOL_CHARS.include? char 
                            @stdout.putc echo_char
                        end
                    ensure
                        system "#{STTY} #{stty_original}"
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

        def colorize(text,color,bold=true)
            before = ""
            after  = ""
            if VALID_COLORS.include?(color) then
                before = ESCAPE + COLORS[color]
                before = ESCAPE + BOLD_ON + before if bold
                after  = ESCAPE + RESET
            end
            "#{before}#{text}#{after}"
        end

        def colorize_if_ok(io,text,color,bold)
            if io.tty? and ( @options.color_scheme != :none ) then
                text = colorize(text,color,bold)
            end
            text
        end

        def color_puts(text, color, bold = true)
            @stdout.puts colorize_if_ok(@stdout,text,color,bold)
        end

        def color_print(text,color, bold = true)
            @stdout.print colorize_if_ok(@stdout,text,color,bold)
        end
    end
end
