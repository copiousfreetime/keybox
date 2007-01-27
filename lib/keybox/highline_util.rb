module Keybox
    # including this module assumes that the class included has 
    # an @highline variable
    module HighLineUtil

        # the scheme to apply when no scheme is allowed so that 
        # everything works as normal
        NONE_SCHEME = {
                :prompt         => [ :clear ], 
                :header         => [ :clear ], 
                :header_bar     => [ :clear ], 
                :line_number    => [ :clear ], 
                :even_row       => [ :clear ], 
                :odd_row        => [ :clear ], 
                :information    => [ :clear ], 
                :error          => [ :clear ], 
                :private        => [ :clear ], 
                :separator      => [ :clear ], 
                :separator_bar  => [ :clear ], 
                :name           => [ :clear ], 
                :value          => [ :clear ], 
        }

        #
        # A whole line of input needs a particular color.  This makes it
        # easy to have all the ERB happening in one spot to avoid
        # escaping issues.
        def hsay(output,color_scheme)
            @highline.say("<%= color('#{output}','#{color_scheme}') %>")
        end

        #
        # Prompt for input, returning what was typed.  Options can be
        # passed as If echo is false,
        # then '*' is printed out for each character typed in.  If it is
        # any other character then that is output instead.
        #
        # If validate is set to true, then it will prompt twice and make
        # sure that the two values match
        def prompt(p,*options)
            validated = false
            line = ""
            extra_prompt = " (again)"
            original_prompt = p
            validation_prompt = original_prompt + extra_prompt

            echo = options.include?(:no_echo) ? '*' : true

            until validated do
                line = @highline.ask("<%= color('#{original_prompt}',:prompt) %> ") { |q| q.echo = echo }
                #line = prompt_and_return(original_prompt.rjust(width),echo)

                # if we are validating then prompt again to validate
                if options.include?(:validate) then
                    v = @highline.ask("<%= color('#{validation_prompt}', :prompt) %> ") { |q| q.echo = echo }
                    #v = prompt_and_return(validation_prompt.rjust(width),echo)
                    if v != line then
                        @highline.say("<%= color('Entries do not match, try again.', :error) %>")
                    else
                        validated = true
                    end
                else 
                    validated = true
                end
            end
            return line
        end
    end
end
