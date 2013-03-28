$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

ENV['RACK_ENV'] = 'test'

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'])

## Configure I18n
I18n.default_locale = :en

require 'rack/test'
require 'webrat'
require 'scorched'
require 'slim'
require 'scorched-responders'
require 'mongo_mapper'

require 'rabl'
Rabl.configure do |config|
  config.include_json_root = false
end

Rabl.register!

MongoMapper.connection = Mongo::Connection.new('localhost') 
MongoMapper.database   = 'scorched_responders_test' 

class Post
  include MongoMapper::Document

  key :title, String
  key :body,  String
  key :num,   Integer

  validates_presence_of :title
end

if Post.count == 0
  5.times do
    Post.create(title: 'Test Title', body: 'Test Body', num: 20)
  end
end

# We set our target application and rack test environment using let. This ensures tests are isolated, and allows us to
# easily swap out our target application.
module GlobalConfig
  extend RSpec::SharedContext
  include Webrat::Methods
  include Webrat::Matchers

  Webrat.configure do |config|
    config.mode = :rack
  end

  def stop_time_for_test
    time = Time.now
    Time.stub(:now).and_return(time)
    return time
  end

  let(:app) do
    class App < Scorched::Controller
      register ScorchedHelpers
      register ScorchedResponders

      middleware << proc {
        use Rack::Session::Cookie, secret: 'garden'
      }

      render_defaults.merge!(engine: :slim)

      def self.controller_name
        return 'posts'
      end

      def self.root
        return File.expand_path('/public', __FILE__)
      end

      post '/error/422' do
        @post = Post.create()
        respond(@post, action: 'error_422', status: :unprocessable_entity)
      end

      get '/to_json' do
        @post = Post.first()
        respond(@post, action: 'to_json', json_engine: :to)
      end

      get '/posts' do
        @posts = Post.all()
        respond(@posts)
      end

      get '/posts/flash' do
        @post = Post.first()
        respond(@post, action: 'flash', location: '/posts', message: 'cats')
      end

      get '/posts/:id' do
        @post = Post.find(captures[:id])
        halt(404) unless @post
        respond(@post, action: 'show')
      end
    end    

    return App.new({})
  end
  
  let(:rt) do
    Rack::Test::Session.new(app)
  end

  let(:stc) do
    class StatusCodesTestClass 
      include Scorched::Responders::StatusCodes
    end
    
    return StatusCodesTestClass.new()
  end
  
  original_dir = __dir__
  before(:all) do
    Dir.chdir(__dir__)
  end
  after(:all) do
    Dir.chdir(original_dir)
  end
end

RSpec.configure do |c|
  c.alias_example_to :they
  c.include GlobalConfig
end
