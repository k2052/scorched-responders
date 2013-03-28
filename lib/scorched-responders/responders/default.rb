module Scorched
  module Responders
    class Default < Base    
      def jsend?
        return true
      end  

      def respond        
        if request.put?
          set_status :ok if valid?
          put
        elsif request.post?
          set_status :created if valid?
          post
        elsif request.delete?
          delete
        else
          default
        end
      end

      def put_or_post(message_type, error_detour)
        message = message(message_type)
        if valid?
          return default(message)
        else
          set_status :unprocessable_entity
          if self.app.mime_type(:json) == self.app.preferred_type.to_s 
            return {:status => self.app.response.status, :message => message, :data => object.errors}.to_json
          else
            notify(:error, message)
            try_render error_detour
          end
        end
      end

      def put
        put_or_post :update, 'edit'
      end

      def post
        put_or_post :create, 'new'
      end

      def delete
        default(message(:destroy))
      end

      def default(message=nil)
        set_status
        message = message() unless message
        if location
          if self.app.mime_type(:json) == self.app.preferred_type.to_s 
            return {:status => self.app.response.status, :message => message, :data => object, :location => location}.to_json
          else
            notify(:notice, message)
            redirect location
          end
        else
          try_render
        end
      end
    end
  end
end
