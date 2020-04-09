# ytvarb

ytvarb is Ruby library for YouTube Video Analytics.
The library accesses YouTube Data API v3 and COTOHA API.

## Installation

```rb
under construction
```

## Setup

1. Before using ytvarb, you should get key and id from YouTube Data API v3 and COTOHA API service.

- API key

  Need to register for YouTube Data API v3

- Client ID and Client secret

  Need to register for COTOHA API

2. Create 'api_key.txt', 'cliend_id.txt' and 'cliend_secret.txt' file newly into config/ directory, then save got key and id.

3. Install some need ruby library

- google-api-client
- cotoha

```rb
$ bundle install
```

or

manually installby yourself

## DB (Data Base)

### Directory structure

```
/db									  
└─	/#{year}						  
	└─	/#{month}					  
		└─	/#{day}					  
			└─	#{video_id}.sqlite3	  
```

---

## Development

Here is for developer

### Directory structure

```
/										  
├─	/app								  
│	└─	get_comment.rb					  
├─	/bin								  
├─	/config								  
│	├─	api_key.txt						  
│	└─	database.yml					  
├─	/db									  
├─	/lib								  
│	├─	/ytvarb							  
│	│	├─	models						  
│	│	│	└─	comment_threads.rb		  
│	│	├─	model.rb					  
│	│	├─	configure.rb				  
│	│	├─	youtube_data_api.rb			  
│	│	└─	version.rb					  
│	└─	ytvarb.rb						  
├─	/log								  
├─	/spec								  
├─	LICENSE								  
└─	README.md							  
```
