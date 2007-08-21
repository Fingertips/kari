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
          render :index_page
        else
          @query = input.q
          @matches = Kari::RI.quick_search @query
          if @matches.empty?
            @message = "Found nothing."
            render :error_page
          elsif @matches.length > 1
            render :overview_page
          else
            @match = Kari::RI.get(@matches.first[:full_name])
            render :entry_page
          end
        end
      end
    end

    class Show < R '/show/(.*)'
      def get(name)
        @match = Kari::RI.get name
        if @match.nil?
          @message = "Can't find “#{name}”."
          render :error_page
        else
          render :entry_page
        end
      end
    end

    class Status < R '/status'
      def get
        @index_status = Kari::RI.status
        headers['X-Status'] = @index_status
        render :status_page
      end
    end

    class Files < R '/(stylesheets|javascripts)/([^/]+)'
      def get(sort, path)
        @headers['Content-Type'] = "text/#{sort == 'stylesheets' ? 'css' : 'javascript'}; charset=utf-8"
        File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources', sort, path)))
      end
    end

    class ServerError
      def get(klass, method, exception)
        r(500, Mab.new do
          xhtml_transitional do
            head do
              title "Something went wrong"
              script :src => R(Files, "javascripts", "error.js"), :type => "text/javascript"
              link :href => R(Files, "stylesheets", "default.css"), :rel => "stylesheet", :type => "text/css"
            end
            body do
              h1.splash do
                a "Something went wrong.", :onclick => "Error.show();return false", :href => "#"
              end
              div.error! :style => 'display:none;' do
                h2 "#{method} #{klass}"
                h3 "#{exception.class} #{exception.message}"
                ul { exception.backtrace.each { |bt| li(bt) } }
              end
            end
          end
        end.to_s)
      end
    end

    class NotFound
      def get(page)
        r(404, Mab.new do
          xhtml_transitional do
            head do
              title "Not found"
              link :href => R(Files, "stylesheets", "default.css"), :rel => "stylesheet", :type => "text/css"
            end
            body do
              h1.splash "Not found."
            end
          end
        end.to_s)
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

    def index_page
      h1.splash "KARI"
      ul do
        %w(String ActiveSupport::Multibyte::Chars ActiveSupport::Multibyte::Handlers::UTF8Handler).each do |full_name|
          li do
            h2 { a full_name, :href => R(Show, full_name) }
          end
        end
      end
    end

    def error_page
      h1.splash message
    end

    def overview_page
      h1 "#{matches.length} entries found for “#{query}”"
      ul.overview do
        matches.each do |entry|
          li do
            a entry[:full_name], :href => R(Show, entry[:full_name])
          end
        end
      end
    end

    def status_page
      h1 index_status
    end

    def entry_page
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
        unless klass.superclass.blank?
          span " < "
          if klass.superclass.kind_of?(String) and 
            span.superclass "#{klass.superclass}"
          else
            span.superclass { a klass.definition.superclass, :href => R(Show, klass.superclass.full_name) }
          end
        end
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
              li inc
            else
              li do
                a inc.full_name, :href => R(Show, inc.full_name)
                unless inc.instance_methods.empty?
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
      end
      unless klass.attributes.empty?
        h2 "Attributes"
        ul do
          klass.attributes.each do |attribute|
            li do
              span.rw attribute.rw.downcase
              span " – "
              span attribute.name
              if attribute.comment
                _flow attribute.comment
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
          span "#{method.separator}#{method.name}"
        else
          span method.full_name
        end
      end
      hr
      p do
        span.visibility method.visibility
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
          method.aliases.each do |method|
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
          self << part.body.split("\n").map { |l| l[2..-1] }.join("\n")
        end
      when SM::Flow::H
        self << "<h#{part.level}>#{part.text}</h#{part.level}>"
      when SM::Flow::RULE
        hr
      end
    end
  end
end