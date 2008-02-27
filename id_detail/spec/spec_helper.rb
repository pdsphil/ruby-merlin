require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + "/../../id_detail"

module RequestSpecHelper
  def test_subject
    return API::IDDetail::Subject.new('123456789')
  end  
end

module ResponseSpecHelper
  def mock_error_response
    return File.read( File.dirname(__FILE__) + '/fixtures/merlin_error_response.xml' )
  end

  def mock_no_match_response
    return File.read( File.dirname(__FILE__) + '/fixtures/merlin_no_match_response.xml' )
  end

  def mock_match_found_response
    return File.read( File.dirname(__FILE__) + '/fixtures/merlin_match_found_response.xml' )
  end

end
