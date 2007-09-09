require 'parsedate'
require 'stringio'

# This plugin creates a 'news' tag which can be used to display the
# contents of a news file.
#
# The news file by default is 'news.yaml' and placed in the root of
# the webby directory.  This can be changed with the +SITE.news_file+
# in setup.rb
#
# The yaml file has the basic format of
#
#   date: content
#   date: content
#
# Where the date has the format indicated by the 'dateFormat'
# parmater, which by default is YYYY-MM-DD.  The content is formated
# according to the 'contentFormat' parameter and is textile by
# default.  I recommend using the '|' version of block text for the
# content.  For example:
#
#   2007-03-20: |
#       h2. this is an entry
#
#       This is some content
#
# When utilzed in a template the 'news' tag can optionally take to
# additional parameters 'maxEntries' and 'maxParagraphs'.  
#
#   max_entries: the N most recent entries by date in the news.yaml
#               file to display.
#
#   max_paragraphs: the content of an entry is truncated to N
#                  paragraphs, where a paragraphs ending is defined by
#                  "\n\n"
# 
# So the following usage of the news tag would disply the first
# paragraph of the most recent item in the news.yaml file.
#
#   <%= news({ :max_entries => 1, :max_paragraphs => 1}) %>
#
# While this usage would display all the contents of the news.yaml file
# sorted in reverse chronological order and displayed fully.
#
#   <%= news %>
#
#
class News

    DATE_FORMAT = "%Y-%m-%d"
    DATE_TAG    = "h2"
    CONTENT_TAG = nil
    
    class << self
        
        # load the entries in reverse chronological order
        def entries
            @entries ||= YAML::load(File.read(SITE.news_file))
        end
        
        def sorted_entries            
            if not @sorted_entries then
                # convert the entries to something sortable by date
                @sorted_entries = []
                entries.each_pair do |date,content|
                    case date
                    when String
                        p = ParseDate.parsedate(date)
                    when Date
                        p = [date.year, date.month, date.day]
                    when DateTime
                        p = [date.year, date.month, date.day, date.hour, date.min, date.sec]
                    end
                    @sorted_entries << { :time => Time.mktime(*p), :content => content }
                end

                # we want a descending sort
                @sorted_entries.sort! { |a,b| b[:time] <=> a[:time] }
            end
            return @sorted_entries.freeze
        end
        
        def format(e)
            content = StringIO.new
            e.each do |entry|
                content.puts "<#{DATE_TAG}> #{entry[:time].strftime(DATE_FORMAT)} </#{DATE_TAG}>"
                content.puts
                content.print "<#{CONTENT_TAG}>" if CONTENT_TAG.to_s.length > 0 
                content.puts RedCloth.new(entry[:content]).to_html
                content.print "</#{CONTENT_TAG}>" if CONTENT_TAG.to_s.length > 0 
                content.puts
            end
            content.string
        end
    end
end

def news(options = {})
    max_entries     = options[:max_entries] || News.sorted_entries.size
    max_paragraphs  = options[:max_paragraphs] || nil
            
    
    to_format = News.sorted_entries.collect do |e|
                    paragraphs = e[:content].split("\n\n")
                    trim_to    = max_paragraphs || paragraphs.size
                    { :time    => e[:time],
                      :content => paragraphs[0...trim_to].join("\n\n") }
                end
    News.format(to_format[0...max_entries])
end
