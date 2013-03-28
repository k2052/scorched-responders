module Scorched
  module Responders
    module Helpers
      module Controller 
        def styled_flash(key=:flash)
          return "" if flash(key).empty?
          id = (key == :flash ? "flash" : "flash_#{key}")
          messages = flash(key).collect {|message| "  <div class='flash #{message[0]}'>#{message[1]}</div>\n"}
          "<div class='#{id}'>\n" + messages.join + "</div>"
        end

        def captures
          request.captures
        end
        
        ##
        # Returns translated, human readable name for specified model.
        #
        def human_model_name(object)
          if object.class.respond_to?(:human)
            object.class.human
          elsif object.class.respond_to?(:human_name)
            object.class.human_name
          else
            t("models.#{object.class.to_s.underscore}", :default => object.class.to_s.humanize)
          end
        end

        ##
        # Returns url
        #
        def back_or_default(default)
          return_to = session.delete(:return_to)
          return_to || default
        end
      end
    end
  end
end
