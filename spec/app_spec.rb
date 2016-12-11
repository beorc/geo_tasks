require 'spec_helper.rb'

describe 'Tasks' do
  it 'works' do
    get '/'
    expect(last_response).to be_ok
  end
end
