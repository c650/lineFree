# TASKS:

###JOHN:
	:Views (GLYPHICONS AND MOBILE)
	:Styling
	:PASSWORDS (do this last) 

###CHARLES:
	:Databases,
	:App controller,
	:xModels -> User, Post, Place

#Model/Migration Layout

###A User has these attributes: 

	:first_name
	:last_name
	:email 
	:username (screen name for post)
	:phone_number (optional) 
	:birthdate (to check for users that are too young)

###A Post has these attributes:

	:place_id (should be able to input address of place while posting, will make new place if place doesn't exist)

	:user_id (taken from session)
	:wait_time (estimate, submitted as dropdown in ranges)
	:people_in_line (estimate, submitted as dropdown in ranges)

###A Place has these attributes:

	:name 
	:type (restaurant or store)
	:address (street address)
	:city
	:state (we start in USA) (must be dropdown for standardization)
	:zipcode (as a string)

# Views Layouts

	Root ('/') page should have a search bar, and buttons for login/logout/signup and creation of post/place

	###Need A:
	
	Root page (see above)
	Search Page
	New post page
	New place page
	New user page
	Login Page
	A dynamic url page for each post & place

