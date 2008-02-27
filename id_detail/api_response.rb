require 'hpricot'

module API
  module IDDetail
    
    class Response
      attr_accessor :raw_response, :parsed_response, :result
      
      def initialize(raw_xml)
        
        # parse the raw xml
        self.raw_response = raw_xml
        self.parsed_response = Hpricot.XML(raw_xml)
        
        # check for an error first
        if ! (self.parsed_response/:errors).empty?
          self.result = "error"
        elsif ((self.parsed_response)/:rows_returned).inner_text == "0"
          self.result = "no-match"
        elsif ((self.parsed_response)/:rows_returned).inner_text.to_i > 0
          self.result = "match"
        end
      end
    end
    
    class SearchResponse < Response
      attr_accessor :identity
      
      def initialize(raw_xml)
        super
        
        # start with empty hashes for the attributes
        initialize_attributes
        
        # only proceed if we have a match
        if self.result == "match"
          parse_nicknames
          parse_identity_records
        end
      end
      
      
      private
      
      def initialize_attributes
        self.identity = {}
        self.identity[:nicknames] = []
        self.identity[:identity_records] = []
      end
      
      def parse_nicknames
        # Nicknames
        nicknames = self.parsed_response/:nicknames/:nickname
        
        if nicknames.inner_text != ""
          nicknames.each do |nick|
            self.identity[:nicknames] << nick.inner_text
          end
        end
      end
      
      def parse_identity_records
        # an identity record corresponds to the info in <response_row>
        (self.parsed_response/:response_row).each do |row|
          
          identity_record = {}
          
          identity_record[:identity_name] = parse_identity_name(row)
          identity_record[:identity_address] = parse_identity_address(row)
          identity_record[:identity_phones] = parse_identity_phones(row)
          
          # add the identity_record to the identity
          self.identity[:identity_records] << identity_record
        end
      end
      
      def parse_identity_name(row)
        # identity name corresponds to a <chdr_name> block
        name = row/:chdr_name
        
        identity_name = {}
        identity_name[:vendor_name] = (name/:cps_vendor_name).inner_text
        identity_name[:last_name] = (name/:lastname).inner_text
        identity_name[:first_name] = (name/:firstname).inner_text
        identity_name[:middle_name] = (name/:middlename).inner_text
        identity_name[:file_date] = (name/:file_date).inner_text
        identity_name[:date_of_birth] = (name/:dob).inner_text
        identity_name[:age] = (name/:age).inner_text
        identity_name[:akas] = []
        
        # add any akas we find
        akas = name/:akas/:aka
        
        if akas.inner_text != ""
          akas.each do |aka|
            identity_name[:akas] << aka.inner_text
          end
        end
        
        return identity_name
      end

      def parse_identity_address(row)
        # address corresponds to a <chdr_address> element
        address = row/:chdr_address
        
        identity_address = {}
        identity_address[:house_number] = (address/:house_number).inner_text
        identity_address[:street_pre_direction] = (address/:street_pre_direction).inner_text
        identity_address[:street_name] = (address/:street_name).inner_text
        identity_address[:street_suffix] = (address/:street_suffix).inner_text
        identity_address[:apartment_number] = (address/:apartment_number).inner_text
        identity_address[:city] = (address/:city).inner_text
        identity_address[:state] = (address/:state).inner_text
        identity_address[:zipcode] = (address/:zipcode).inner_text
        identity_address[:zip4] = (address/:zip4).inner_text
        identity_address[:address_type_code] = (address/:address_type_code).inner_text
        identity_address[:address_date] = (address/:address_date).inner_text
        
        # split the <date_reported> field if there is a hyphen
        date = (address/:date_reported).inner_text
        if date.include?("-")
          identity_address[:first_date_reported] = date.split("-")[1]
          identity_address[:last_date_reported] = date.split("-")[0]
        else
          identity_address[:first_date_reported] = identity_address[:last_date_reported] = date
        end
        
        identity_address[:county_name] = (address/:county_name).inner_text
        
        # add any phone number we find
        identity_address[:phone_numbers] = []
        phone_numbers = address/:phone_numbers/:phone_number
        
        if phone_numbers.inner_text != ""
          phone_numbers.each do |phone_number|
            identity_address[:phone_numbers] << phone_number.inner_text
          end
        end
        
        return identity_address
      end
      
      def parse_identity_phones(row)
        # phones corresponds to a <listed_phones> element
        listed_numbers = row/:listed_phones/:result
        
        numbers = []
        
        if listed_numbers.inner_text != ""
          listed_numbers.each do |number|
            phone_number = {}
            phone_number[:area_code] = (number/:area_code).inner_text
            phone_number[:phone_number] = (number/:phone).inner_text
            
            numbers << phone_number
          end
        end
        
        return numbers
      end
      
    end

  end
end
