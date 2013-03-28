require_relative './helper.rb'

describe 'StatusCodes' do
  it 'should return a status message from a number' do
    stc.interpret_status(422).should eq 422
  end

  it 'should return a status message from a symbol' do
    stc.interpret_status(:created).should eq 201
  end
end
