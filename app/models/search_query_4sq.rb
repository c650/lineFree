require "httparty"

def search_query(user,query)
	CLIENT_ID = ""
	CLIENT_SECRET = ""
    uri = "https://api.foursquare.com/v2/venues/search?near=#{user.home_city},#{user.home_state}&query=#{query}"
    encoded = URI.parse(URI.encode(uri)) # to handle spaces in the location
    @api_response = HTTParty.get(encoded)
    results = Array.new
    @api_response['response']['venues'].each do |venue|
    	place = Place.find_or_create_by(name: venue['name'], address: venue['location']['address'], city: venue['location']['city'], state: venue['location']['state'], zipcode: venue['location']['postalCode'])
    	results.push(place)
    end
    #PARSE THRU DATA TO RETURN ARRAY OF PLACES
    return results
end
