require 'scorched-helpers'

FileSet.glob_require('scorched-responders/*.rb', __FILE__)
FileSet.glob_require('scorched-responders/{helpers,notifiers,responders}/*.rb', __FILE__)

module ScorchedResponders
  class << self
    ##
    # Registers helpers into your application:
    #
    def registered(app)
      app.helpers Scorched::Responders::Helpers::Types
      app.helpers Scorched::Responders::Helpers::Controller
      app.helpers Scorched::Responders::Helpers::Respond
      app.set :notifier, Scorched::Responders::Notifiers::FlashNotifier
    end
    alias :included :registered
  end
end

I18n.load_path += Dir["#{File.dirname(__FILE__)}/scorched-responders/locale/**/*.yml"]
