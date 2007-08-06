$KCODE = 'u'

require 'camping'
require 'kari/search'

Camping.goes :Kari
I = Kari::Search::Index.new

module Kari
  module Controllers
    class Index < R '/'
      def get
        render :index
      end
    end

    class Search < R '/search'
      def get
        if input.q.blank?
          render :index
        else
          @q = input.q
          begin
            @results = I.search @q
            @results.gsub!('&lt;tt&gt;', '<tt>')
            @results.gsub!('&lt;/tt&gt;', '</tt>')
          rescue RiError => e
            unless e.message.starts_with?('Nothing known about')
              @results = "<pre>#{e.message}</pre>"
            else
              @results = nil
            end
          end
          render :result
        end
      end
    end

    class Files < R '/stylesheets/([^/]+)'
      def get(path)
        @headers['Content-Type'] = 'text/css; charset=utf-8'
        File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources', 'stylesheets', path)))
      end
    end
  end

  module Views
    def layout
      xhtml_transitional do
        head do
          title 'Kari · Search for Ruby documentation'
          link :href => '/stylesheets/default.css', :rel => 'stylesheet', :type => 'text/css'
        end
        body do
          yield
        end
      end
    end

    def index
      h1.splash 'KARI'
    end

    def result
      unless results.blank?
        self << results
      else
        h1.splash "Nothing found."
      end
    end
  end
end