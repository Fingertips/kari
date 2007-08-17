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

    class Show < R '/show/(.*)'
      def get(name)
        @match = Kari::RI.get name
        if @match.nil?
          @message = "Can't find “#{name}”."
          render :error
        else
          render :entry
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
      ul do
        %w(String ActiveSupport::Multibyte::Chars ActiveSupport::Multibyte::Handlers::UTF8Handler).each do |full_name|
          li do
            h2 { a full_name, :href => R(Show, full_name) }
          end
        end
      end
    end

    def error
      h1.splash message
    end

    def overview
      h1 "#{matches.length} entries found for “#{query}”"
      ul do
        matches.each do |entry|
          li do
            a entry.full_name, :href => R(Show, entry.full_name)
          end
        end
      end
    end

    def entry
      if match.class?
        _class_entry(match)
      else
        _method_entry(match)
      end
    end

    def _class_entry(klass)
      h1 do
        unless match.path.blank?
          a match.path, :href => R(Show, match.path)
          span "::#{match.name}"
        else
          span match.name
        end
        span.superclass " < #{klass.superclass}" unless klass.superclass.blank?
      end
      hr
      unless klass.comment.blank?
        div.comment do
          _flow(klass.comment)
        end
      end
      unless klass.instance_methods.empty?
        h2 "Instance methods"
        ul do
          klass.instance_methods.each do |method|
            li { a method.name, :href => R(Show, method.full_name) }
          end
        end
      end
      unless klass.class_methods.empty?
        h2 "Class methods"
        ul do
          klass.class_methods.each do |method|
            li { a method.name, :href => R(Show, method.full_name) }
          end
        end
      end
      unless klass.includes.empty?
        h2 "Includes"
        ul do
          klass.includes.each do |inc|
            if inc.is_a?(String)
              li inc.name
            else
              li do
                a inc.full_name, :href => R(Show, inc.full_name)
                span do
                  self << " ("
                  self << inc.instance_methods.map { |m| a m.name, :href => R(Show, m.full_name) }.to_sentence
                  self << ")"
                end
              end
            end
          end
        end
      end
      unless klass.attributes.empty?
        h2 "Attributes"
        ul do
          klass.attributes.each do |attribute|
            li do
              span.rw attribute.rw
              span " – "
              span attribute.name
              if attribute.comment
                span " (#{attribute.comment})"
              end
            end
          end
        end
      end
      unless klass.constants.empty?
        h2 "Constants"
        table do
          klass.constants.each do |constant|
            tr do
              td constant.name
              td { code constant.value }
            end
            unless constant.comment.blank?
              tr.comment do
                td :colspan => 2 do
                  _flow constant.comment
                end
              end
            end
          end
        end
      end
    end

    def _method_entry(method)
      h1 do
        unless method.path.blank?
          a method.path, :href => R(Show, method.path)
          span "::#{method.name}"
        else
          span method.full_name
        end
      end
      hr
      p.signature do
        span method.visibility
        self << " "
        if method.params.starts_with?('(')
          span method.name + method.params
        else
          span method.params
        end
      end
      unless method.comment.blank?
        div.comment do
          _flow(method.comment)
        end
      end
      unless method.aliases.empty?
        h2 "Aliases"
        ul do
          method.aliases do |method|
            li { a method.name, :href => R(Show, method.full_name) }
          end
        end
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