require 'camping'

Camping.goes :Kari

module Kari
  module Controllers
    class Index < R '/'
      def get
        render :index
      end
    end

    class Files < R '/stylesheets/([^/]+)'
      def get(path)
        @headers['Content-Type'] = 'text/css'
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
  end
end