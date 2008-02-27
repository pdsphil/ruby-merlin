require File.dirname(__FILE__) + '/spec_helper'

include API::Base
include API::IDDetail

describe Response do
  
  include ResponseSpecHelper
  
  it "should be able to parse the raw xml of a response" do
    response = Response.new(mock_error_response)
    response.raw_response.should_not be_nil
    response.parsed_response.should_not be_nil
  end
  
  it "should be able to detect an error response" do
    response = Response.new(mock_error_response)
    response.result.should eql("error")
  end
  
  it "should be able to detect a no-match response" do
    response = Response.new(mock_no_match_response)
    response.result.should eql("no-match")
  end
  
  it "should be able to detect a valid match response" do
    response = Response.new(mock_match_found_response)
    response.result.should eql("match")    
  end
end

describe SearchResponse do
  
  include ResponseSpecHelper
  
  before(:each) do
    @search = SearchResponse.new(mock_match_found_response)
  end
  
  it "should find any nicknames returned" do
    @search.identity[:nicknames].should_not be_empty
    @search.identity[:nicknames].size.should eql(2)
    @search.identity[:nicknames][0].should eql("Test")
    @search.identity[:nicknames][1].should eql("Test2")
  end
  
  it "should parse the identity records found" do
    @search.identity[:identity_records].should_not be_nil
    @search.identity[:identity_records].size.should eql(10)
  end
  
  it "should parse the identity name for each identity record found" do
    @search.identity[:identity_records].each do |identity_record|
      identity_record[:identity_name].should_not be_nil
    end
    
    # instead of checking all 10 identity names, we'll check just the first
    identity_name = @search.identity[:identity_records][0][:identity_name]
    identity_name[:vendor_name].should eql("TransUnion - Pre GLB")
    identity_name[:last_name].should eql("DAVIS")
    identity_name[:first_name].should eql("RICHARD")
    identity_name[:middle_name].should eql("T")
    identity_name[:file_date].should eql("")
    identity_name[:date_of_birth].should eql("196801??")
    identity_name[:age].should eql("39")
    identity_name[:akas].should_not be_empty
    identity_name[:akas][0].should eql("DAVIS TODD R")
  end
  
  it "should parse the identity address for each identity record found" do
    @search.identity[:identity_records].each do |identity_record|
      identity_record[:identity_address].should_not be_nil
    end
    
    # only check the first identity address
    identity_address = @search.identity[:identity_records][0][:identity_address]
    identity_address[:house_number].should eql("881")
    identity_address[:street_pre_direction].should eql("N")
    identity_address[:street_name].should eql("GRANADA")
    identity_address[:street_suffix].should eql("DR")
    identity_address[:apartment_number].should eql("")
    identity_address[:city].should eql("CHANDLER")
    identity_address[:state].should eql("AZ")
    identity_address[:zipcode].should eql("85226")
    identity_address[:zip4].should eql("2370")
    identity_address[:address_type_code].should eql("C")
    identity_address[:address_date].should eql("200010")
    identity_address[:first_date_reported].should eql("199908")
    identity_address[:last_date_reported].should eql("200701")
    identity_address[:county_name].should eql("MARICOPA")
    identity_address[:phone_numbers].should_not be_empty
    identity_address[:phone_numbers][0].should eql("4591200")
    identity_address[:phone_numbers][1].should eql("4806991772")
  end
  
  it "should parse the listed phone numbers for an identity record" do
    @search.identity[:identity_records].each do |identity_record|
      identity_record[:identity_phones].should_not be_nil
    end
    
    # only check the first identity phone
    identity_phones = @search.identity[:identity_records][0][:identity_phones]
    identity_phones.size.should eql(1)
    identity_phones[0][:area_code].should eql("480")
    identity_phones[0][:phone_number].should eql("6991XXX")
  end
  
end

