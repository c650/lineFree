require 'httparty'
# require 'pry'
require 'geocoder'
class Neighborhood

  ##!!!NEEDS TO BE FILLED OUT WITH CLIENT ID AND SECRET PROVIDED BY FOURSQUARE
  CLIENT_ID = ""
  CLIENT_SECRET = ""

  def search_query(lat, long, query)
    uri = "https://api.foursquare.com/v2/venues/search?ll=#{lat},#{long}&query=#{query}&intent=checkin&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&v=20150716"
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
