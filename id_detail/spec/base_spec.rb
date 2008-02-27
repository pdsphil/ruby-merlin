require File.dirname(__FILE__) + '/spec_helper'

include API::Base
include API::IDDetail

describe BasicAccessCredentials do
  it "should initialize with a username and password hash" do
    credentials = BasicAccessCredentials.new({:username => 'user', :password => 'pass'})
    credentials.username.should eql('user')
    credentials.password.should eql('pass')
  end
end

describe Subject do
  
  include ResponseSpecHelper
  
  it "should initialize with an API Service model" do
    subject = Subject.new
    subject.api_service.should_not be_nil
    subject.api_service.should be_an_instance_of(API::IDDetail::Service)
  end
  
  it "should initialize with optional data" do
    subject = Subject.new('123456789')
    subject.ssn.should eql('123456789')
  end
  
  it "should be able to locate itself" do
    subject = Subject.new
    subject.api_service.stub!(:locate).and_return(API::IDDetail::SearchResponse.new(mock_match_found_response))
    
    subject.locate.should be_true
  end
  
  it "should be able to load an identity from local fixtures when directly told to" do
    subject = Subject.new
    subject.locate(true).should be_true
    subject.identity.should_not be_nil
  end

end

describe Service do
  
  include RequestSpecHelper
  include ResponseSpecHelper
  
  before(:each) do
    @service = Service.new
  end
  
  it "should be able to find a subject" do
    @service.stub!(:ssl_post).and_return(mock_match_found_response)
    @service.locate(test_subject).should be_an_instance_of(API::IDDetail::SearchResponse)
    @service.api_search_response.should be_an_instance_of(API::IDDetail::SearchResponse)
  end
  
  it "should simulate an API response when directly told to" do
    @service.locate(test_subject, true).should be_an_instance_of(API::IDDetail::SearchResponse)
    @service.api_search_response.should be_an_instance_of(API::IDDetail::SearchResponse)    
  end
    
  it "should be able to handle an Exception in locate() when calling the API" do
    @service.stub!(:ssl_post).and_raise(Exception)
    lambda { @service.locate(test_subject) }.should raise_error(ServiceError)
  end

end

