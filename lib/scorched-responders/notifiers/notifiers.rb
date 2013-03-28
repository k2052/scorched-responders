module Scorched
  module Responders
    module Notifiers
      module FlashNotifier
        def self.say(app, kind, message, *args, &block)
          app.flash[kind.to_sym] = message
        end
      end
    end 
  end 
end
