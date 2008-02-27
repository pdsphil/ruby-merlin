require 'net/http'
require 'net/https'
require 'logger'

module API
  module IDDetail
    
    class Service
      include API::Base # for error classes
      
      attr_accessor :api_search_response
      
      def locate(subject, use_fixture = false)
        # locate is a Merlin API call
        
        # new SearchRequest Object
        search_request = API::IDDetail::SearchRequest.new
        
        # assemble the data in a hash for the POST
        search_request.set_data(subject)
        
        # for debugging locally using spec fixtures - tied to the use_fixture param
        if use_fixture
          response = API::IDDetail::SearchResponse.new( File.read( File.dirname(__FILE__) + "/spec/fixtures/merlin_match_found_response.xml" ) )
        else
          # make the call
          response = API::IDDetail::SearchResponse.new( ssl_post(search_request.url, search_request.data) )
        end
        
        self.api_search_response = response
        
        return response
        
      rescue Exception => err
        log_error(err, 'locate()')
        
        # raise a generic error for the caller
        raise ServiceError
      end
      
      
      private
      
      def ssl_post(url, data, headers = {})
        url = URI.parse(url)

        # create a Proxy class, incase a proxy is being used - will work even if proxy options are nil
        connection = Net::HTTP.new(url.host, url.port)
        
        connection.use_ssl = true
        
        if ENV['RAILS_ENV'] == 'production'
          # we want SSL enforced via certificates
          connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
          connection.ca_file = File.dirname(__FILE__) + "/certs/cacert.pem"
        else
          # do not enforce SSL in dev modes
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
          
          # for debugging
          connection.set_debug_output $stderr
        end
        
        connection.start { |https|
          # setup the POST request
          req = Net::HTTP::Post.new(url.path)
          req.set_form_data(data, '&')
          
          # do the POST and return the response body
          return https.request(req).body
        }
      end

      def log_error(err, method_name)
        logger = Logger.new(File.dirname(__FILE__) + "/log/error.log")
        logger.error "Merlin API Error in Service.#{method_name} - " + err.message
        logger.close
      end
      
    end
    
    class Subject
      include API::Base # for error classes
      
      attr_accessor :ssn
      attr_accessor :api_service, :identity, :raw_source
      
      def initialize(ssn = "")
        self.api_service = API::IDDetail::Service.new
        self.ssn = ssn
      end
      
      def locate(use_fixture = false)
        response = self.api_service.locate(self, use_fixture)
        
        if response.result == "match"
          self.identity = response.identity
          self.raw_source = response.raw_response
          return true
        elsif response.result == "no-match"
          return false
        elsif response.result == "error"
          return false
        else
          return false
        end
      rescue ServiceError
        return false
      end
      
    end
    
  end
end