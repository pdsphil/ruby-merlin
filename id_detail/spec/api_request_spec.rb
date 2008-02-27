require File.dirname(__FILE__) + '/spec_helper'

include API::Base
include API::IDDetail

describe Request do
  it "should initialize with credentials from config.yml" do
    API::IDDetail::Request.stub!(:config).and_return(File.dirname(__FILE__) + "/../spec/fixtures/sample_config.yml")
    req = API::IDDetail::Request.new
    req.credentials.username.should eql("test_username")
    req.credentials.password.should eql("test_password")
  end
end

describe SearchRequest do
  
  include RequestSpecHelper
  
  before(:each) do
    API::IDDetail::Request.stub!(:config).and_return(File.dirname(__FILE__) + "/../spec/fixtures/sample_config.yml")
    @search_request = SearchRequest.new
  end
  
  it "should initialze with a url" do
    @search_request.url.should eql('https://lta.merlindata.com/SearchASPs/GW/CH/Results.asp')
  end
  
  it "should initialize with a username and password" do
    @search_request.credentials.username.should eql("test_username")
    @search_request.credentials.password.should eql("test_password")
  end
  
  it "should be able to set its own data given a subject" do
    @search_request.data.should be_nil
    @search_request.set_data(test_subject)
    @search_request.data[:UserId].should eql("test_username")
    @search_request.data[:Password].should eql("test_password")
    @search_request.data[:SSN].should eql('123456789')
    @search_request.data[:Return].should eql('XML')
    @search_request.data[:GLBPurpose].should eql(5)
    @search_request.data[:SearchType].should eql(25)
  end
end
