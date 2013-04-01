module Scorched
  module Responders
    module Helpers
      module Respond
        ##
        # Shortcut for <code>notifier.say</code> method.
        #
        def notify(kind, message, *args, &block)
          settings.notifier.say(self, kind, message, *args, &block) if settings.notifier
        end

        def respond(object, *options)  
          if options.include?(:responder)
            responder = ::Scorched::Responders.const_get("#{options[:responder]}").new
          else
            responder = Scorched::Responders::Default.new
          end        

          responder.options[:location] = options.shift if options.first.is_a?(String)    
          responder.options.merge!(options.extract_options!)

          responder.options[:default_engine] = self.class.render_defaults[:engine]
          responder.options[:layout]         = self.class.render_defaults[:layout]
          responder.options[:layout]         = false if mime_type(:json) == preferred_type.to_s || mime_type(:xml) == preferred_type.to_s
          
          responder.object  = object  
          responder.app     = self

          return responder.respond    
        end

        ##
        # Trys to render and then falls back to to_format
        #
        def try_render(object, detour_name=nil, responder)
          engine = responder.derive_engine_name_from_format
          begin    
            if engine == :to
              if mime_type(:json) == preferred_type.to_s 
                if responder.jsend? && object.respond_to?(:attributes)
                  return {:status => response.status, :data => object.attributes}.to_json
                else
                  return object.to_json if object.respond_to?(:to_json)
                end
              end

              if mime_type(:xml) == preferred_type.to_s
                return object.to_xml if object.respond_to?(:to_xml)
              end
            else
              render responder.view_name, responder.render_options
            end
          rescue Exception => e
            raise ::Scorched::Responders::ResponderError, e.message
          end
        end
      end
    end
  end
end
