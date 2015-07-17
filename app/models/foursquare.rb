require 'httparty'
require 'pry'
class Neighborhood

  ##!!!NEEDS TO BE FILLED OUT WITH CLIENT ID AND SECRET PROVIDED BY FOURSQUARE
  CLIENT_ID = "5RNFE5VSYATZNDR5ISG1FHGD0K5J3H0WZD4J101RRYFKFMP2"
  CLIENT_SECRET = "FZUW1M5UIGGKHRR4KUHMKGQL15R14A4VKYWX42Y2KT10X01F"

  def search_query(user, query)

    uri = "https://api.foursquare.com/v2/venues/search?near=#{user.home_city},#{user.home_state}&query=#{query}&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&v=20150716"
    encoded = URI.parse(URI.encode(uri)) # to handle spaces in the location
    @api_response = HTTParty.get(encoded)
    results = Array.new
    @api_response['response']['venues'].each do |venue|
      place = Place.find_or_create_by(name: venue['name'].downcase, address: venue['location']['address'], city: venue['location']['city'].downcase, state: venue['location']['state'], zipcode: venue['location']['postalCode'])
      results.push(place)
    end
    #PARSE THRU DATA TO RETURN ARRAY OF PLACES
    return results
  end

end
