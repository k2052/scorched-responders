require_relative './helper.rb'

describe 'Responders' do
  it 'should return an error response' do
    response = rt.post('/error/422')
    response.status.should eq 422
  end

  it 'should return an error response with a json message' do
    rt.header 'Accept', 'application/json' 
    response = rt.post('/error/422')

    json = MultiJson.load(response.body)
    json['message'].should eq "Title can't be blank"
    response.status.should eq 422
  end

  it 'should return a json post object' do
    post = Post.first()

    rt.header 'Accept', 'application/json' 
    response = rt.get("/posts/#{post.id}")

    json = MultiJson.load(response.body)
    json['title'].should eq post.title
  end

  it 'should return an html page with a post title' do
    post     = Post.first()
    response = rt.get("/posts/#{post.id}")

    response.body.should have_selector('.title', :content => post.title)
  end

  it 'should return all the posts in a json object' do
    rt.header 'Accept', 'application/json' 
    response = rt.get('/posts')

    json = MultiJson.load(response.body)
    json.first['title'].should_not be_blank
  end

  it 'should return all the posts in a json object' do
    post     = Post.first()
    response = rt.get('/posts')
    response.body.should have_selector('.first_post_title', :content => post.title)
  end

  it 'should return a single post using to_json instead of render with rabl' do
    post = Post.first()

    rt.header 'Accept', 'application/json' 
    response = rt.get('/to_json')

    json = MultiJson.load(response.body)
    json['data']['title'].should eq post.title
  end

  it 'should return a flash message view json' do
    post = Post.first()

    rt.header 'Accept', 'application/json' 
    response = rt.get('/posts/flash')

    json = MultiJson.load(response.body)
    json['data']['title'].should eq post.title
    json['message'].should eq 'cats'
    json['location'].should eq '/posts'
  end

  it 'should a flash a message' do
    response = rt.get('/posts/flash')
    response.should be_redirect

    response = rt.follow_redirect!
    response.body.should have_selector '.flash.notice', :content => 'cats'
  end
end