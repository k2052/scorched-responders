# So you want to respond to something.

scorched-responders is a collection of responders to dry up your [Scorched](https://github.com/Wardrop/Scorched) controllers. It's like magic, only with less magic and more amazement.

# Installation/Usage

For the the time being you need to use my fork of Scorched, which adds support for extensions to Scorched.
You also need my [scorched-helpers](http://github.com/bookworm/scorched-helpers) gem.

Just add the following to your Gemfile

```ruby
gem 'scorched',            git: 'git://github.com/bookworm/Scorched.git'
gem 'scorched-helpers',    git: 'git://github.com/bookworm/scorched-helpers.git'
gem 'scorched-responders', git: 'git://github.com/bookworm/scorched-responders.git'
```

It's a good idea to pick a commit ID and specify it in your Gemfile in case I commit broken changes to master.

```ruby
gem 'scorched', git: 'git://github.com/bookworm/Scorched.git', ref: '7e4faf7aea36151c9414480d929104fa0525d325'
```

Adding the extension is fairly simple and should be familiar to you if have used Sinatra or Padrino.

```ruby
require 'scorched-helpers'
require 'scorched-responders'
class App < Scorched::Controller
  register ScorchedHelpers
  register ScorchedResponders
  
  def self.controller_name
    return 'posts'
  end
  
  get '/posts' do
    @posts = Post.all()
    respond(@posts)
  end
  
  get '/posts/:id' do
    @post = Post.find(captures[:id])
    halt(404) unless @post
    respond(@post, action: 'show')
  end
end
run App
```

Dig over the specs for some usage examples.

## Support

If you found this repo useful please consider supporting me on [Gittip](https://www.gittip.com/k2052) or sending me some
bitcoin `1csGsaDCFLRPPqugYjX93PEzaStuqXVMu`

