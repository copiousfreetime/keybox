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
#   maxEntries: the N most recent entries by date in the news.yaml
#               file to display.
#
#   maxParagraphs: the content of an entry is truncated to N
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
                    @sorted_entries << [Time.mktime(*p), content]
                end

                # we want a descending sort
                @sorted_entries.sort! { |a,b| b[0] <=> a[0] }
            end
            return @sorted_entries
        end
        
        def format(e)
            content = StringIO.new
            e.each do |datetime,entry|
                content.puts "#{DATE_TAG}. #{datetime.strftime(DATE_FORMAT)}"
                content.puts
                content.print "<#{CONTENT_TAG}>" if CONTENT_TAG.to_s.length > 0 
                content.puts entry
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
    
    to_format = News.sorted_entries[0...max_entries]
    if max_paragraphs then
        max_paragraphs = max_paragraphs.to_i
        to_format = News.sorted_entries[0...max_entries].collect do |e|
            e[1] = e[1].split("\n\n")[0...max_paragraphs].join("\n\n")
            e
        end
    end
 
    News.format(to_format)
end
