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
            match = I.search @q
            @match = match.last
            render "#{match.first}_entry"
          rescue RiError => e
            unless e.message.starts_with?("Nothing known about")
              @error = e.message
            else
              @error = "Found nothing."
            end
            render :error
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
      h1.splash @error
    end

    def method_entry
      h1 match.name
      hr
      if match.params.starts_with?('(')
        signature = match.is_singleton ? match.full_name + match.params : match.name + match.params
      else
        signature = match.params
      end
      p.signature signature
      unless match.comment.blank?
        div.comment do
          _flow(match.comment)
        end
      else
        p.missing "No description"
      end
    end

    def methods_entry
      h1 "Found multiple methods"
      p do
        match.map { |k| a(:href => R(Kari::Controllers::Search, :q => k.full_name)) { k.full_name } }.to_sentence(:connector => "or", :skip_last_comma => true)
      end
    end

    def class_entry
      h1 do
        span.klass match.full_name
        if match.superclass_string
          span '<'
          span.superclass match.superclass_string
        end
      end
      hr
      _flow(match.comment)
    end

    def classes_entry
      h1 "Found multiple classes"
      p do
        match.map { |k| a(:href => R(Kari::Controllers::Search, :q => k.full_name)) { k.full_name } }.to_sentence(:connector => "or", :skip_last_comma => true)
      end
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