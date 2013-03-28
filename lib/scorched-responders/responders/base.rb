module Scorched
  module Responders
    class ResponderError < RuntimeError
    end
    class Base
      include Scorched::Responders::StatusCodes
      attr_accessor :options, :object, :app

      def initialize
        @options = {
          :json_engine    => :rabl,
          :xml_engine     => :rabl,
          :action         => 'index',
          :default_engine => :slim
        }
      end

      # Jsend format?
      def jsend?
        return false
      end

      def derive_engine_name_from_format
        case self.app.preferred_type.to_s
        when self.app.mime_type(:json)
          return @options[:json_engine]
        when self.app.mime_type(:xml)
          return @options[:xml_engine]
        else
          return @options[:default_engine]
        end
      end

      def render_options
        options = {}
        options[:layout] = @options[:layout] if @options[:layout]
        options[:engine] = derive_engine_name_from_format
        options
      end

      def view_extension
        reverse_mime_type(media_type)
      end

      def view_name
        return @options[:view] if @options[:view]
        append = 'html'
        append = self.app.reverse_mime_type(self.app.media_type).to_s unless self.app.reverse_mime_type(self.app.media_type).to_s.blank?

        "#{controller_name}/#{action_name}.#{append}"
      end

      ##
      # Returns name of current action
      #
      def action_name
        @options[:action]
      end

      ##
      # Returns name of current controller
      #
      def controller_name
        return self.app.class.controller_name if self.app.class.respond_to?(:controller_name)
        return object.class.to_s.pluralize
      end

      def message(type=nil)
        return @options[:message]         if @options[:message]
        return @options[:error_message]   if @options[:error_message]   and !valid
        return @options[:success_message] if @options[:success_message] and valid
  
        return object.errors.full_messages[0] if !valid?

        object_notice      = "responder.messages.#{controller_name}.#{type}"
        alternative_notice = "responder.messages.default.#{type}"

        object_notice      = self.app.t(object_notice, :model => human_model_name)
        alternative_notice = self.app.t(alternative_notice, :model => human_model_name)

        return object_notice      unless object_notice.blank?
        return alternative_notice unless alternative_notice.blank?

        return 'No message found in locale'
      end

      def valid?
        valid = true

        # `valid?` method may override existing errors, so check for those first
        valid &&= (object.errors.count == 0) if object.respond_to?(:errors)
        valid &&= object.valid?              if object.respond_to?(:valid?)

        return valid
      end

      def request
        self.app.request
      end

      def notify(kind, message, *args, &block)
        self.app.notify(kind, message, *args, &block)
      end

      def try_render(detour_name=nil)
        self.app.try_render(object, detour_name, self)
      end

      def redirect(args)
        self.app.redirect(args)
      end

      def human_model_name
        self.app.human_model_name(object)
      end

      def location
        @options[:location]
      end  
      
      def layout
        return @options[:layout] if @options.include?(:layout)   
      end

      def set_status(status=nil)
        if status.is_a?(Integer)
          self.app.response.status = status
        elsif status.is_a?(String)
          self.app.response.status = interpret_status(status)
        else
          self.app.response.status = interpret_status(@options[:status]) if @options[:status]
        end
      end
    end
  end
end
