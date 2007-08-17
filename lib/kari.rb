$KCODE = 'u'

require 'camping'
require 'kari/ri'

Camping.goes :Kari

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
          @query = input.q
          @matches = Kari::RI.search @query
          if @matches.empty?
            @message = "Found nothing."
            render :error
          elsif @matches.length > 1
            render :overview
          else
            @match = @matches.first
            render :entry
          end
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
          title "Kari · Search for Ruby documentation"
          link :href => "/stylesheets/default.css", :rel => "stylesheet", :type => "text/css"
        end
        body do
          yield
        end
      end
    end

    def index
      h1.splash "KARI"
    end

    def error
      h1.splash message
    end

    def overview
      h1 "#{matches.length} entries found for “#{query}”"
      ul do
        matches.each do |entry|
          li entry.full_name
        end
      end
    end

    def entry
      if match.class?
        _class_entry(match)
      else
        h1 match.name
        hr
        signature = match.is_singleton ? match.full_name + match.params : match.name + match.params
        p.signature signature
        unless match.comment.blank?
          div.comment do
            _flow(match.comment)
          end
        end
      end
      div match.definition.inspect
    end

    def _class_entry(klass)
      h1 klass.full_name
    end

    def _flow(flow)
      flow.each do |part|
        _flow_part(part)
      end
    end

    def _flow_list(list)
      # TODO: better support for the various list types
      ul do
        list.contents.each do |item|
          _flow_part(item)
        end
      end
    end

    def _flow_part(part)
      case part
      when SM::Flow::P
        p do
          self << part.body
        end
      when SM::Flow::LI
        li do
          self << part.body
        end
      when SM::Flow::LIST
        _flow_list(part)
      when SM::Flow::VERB
        pre do
          self << part.body
        end
      when SM::Flow::H
        self << "<h#{part.level}>#{part.text}</h#{part.level}>"
      when SM::Flow::RULE
        hr
      end
    end
  end
end