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
    if (@api_response['response']['venues'].empty? == false) && (@api_response['response']['venues'] != nil)
      @api_response['response']['venues'].each do |venue|
        place = Place.find_or_create_by(name: venue['name'], address: venue['location']['address'], city: venue['location']['city'], state: venue['location']['state'], zipcode: venue['location']['postalCode'])
        results.push(place)
      end
    else
      results = []
    end
    return results
  end

end
