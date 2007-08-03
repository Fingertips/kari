require 'camping'

Camping.goes :Kari

module Kari
  module Controllers
    class Index < R '/'
      def get
        render :index
      end
    end
  end

  module Views
    def layout
      xhtml_strict do
        head do
          title 'Kari · Search for Ruby documentation'
        end
        body do
          yield
        end
      end
    end

    def index
      h1 'Welcome to Kari, please enter your search'
      _form
    end

    def result
      h1 "Results for: #{@q}"
      _form
      self << @results
    end

    def _form
      form :action => '/', :method => 'get' do
        div do
          label do
            text 'Search:'
            input :type => 'text', :name => 'q', :class => 'search', :value => '', :size => 60
          end
        end
      end
    end
  end
end