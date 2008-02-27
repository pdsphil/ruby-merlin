require 'yaml'

module API
  module IDDetail
    
    class Request < API::Base::Request
      attr_accessor :data
      
      class << self
        attr_accessor :config
      end
         
      # test for config file
      if ! File.exist?(File.dirname(__FILE__) + "/config.yml")
        raise Exception, "config file for API::IDDetail not present - try reading the README file"
      end

      # must be in the same directory as this file
      self.config = File.dirname(__FILE__) + "/config.yml"
      
      def initialize
        config = YAML::load(File.open(Request.config))
        self.credentials = API::Base::BasicAccessCredentials.new(:username => config['username'], :password => config['password'])
      end
    end
    
    class SearchRequest < Request
      
      def initialize
        # corresponds to Merlin API call
        self.url = 'https://lta.merlindata.com/SearchASPs/GW/CH/Results.asp'
        
        super
      end
      
      def set_data(subject)
        data_to_send = {
          :UserId => self.credentials.username, 
          :Password => self.credentials.password, 
          :SSN => subject.ssn, 
          :Return => 'XML', 
          :GLBPurpose => 5, 
          :SearchType => 25
        }
        
        self.data = data_to_send
      end
    end

  end
end
