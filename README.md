# ytvarb

ytvarb is Ruby library to analyze comment of YouTube video.

The library uses the service of [YouTube Data API v3](https://developers.google.com/youtube/v3) and [COTOHA API](https://api.ce-cotoha.com/contents/index.html) both.

## Setup

1. Before using ytvarb, you should get key and id from YouTube Data API v3 and COTOHA API service.

- API key

  Need to register for YouTube Data API v3

- Client ID and Client secret

  Need to register for COTOHA API

2. Create 'api_key.txt', 'client_id.txt' and 'client_secret.txt' file newly into config/ directory, then save got key and id.

3. Install some need ruby library

- google-api-client
- cotoha

```
$ bundle install
```

or

manually install by yourself

## Usage

```
$ ruby youtube_video_analytics.rb --video_id [VIDEO ID]
```

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
│	└─	youtube_video_analysis.rb		  
├─	/bin								  
├─	/config								  
│	├─	api_key.txt						  
│	└─	database.yml					  
├─	/db									  
├─	/lib								  
│	├─	/ytvarb							  
│	│	├─	models						  
│	│	│	├─	comment.rb				  
│	│	│	└─	comment_thread.rb		  
│	│	├─	model.rb					  
│	│	├─	configure.rb				  
│	│	├─	youtube_comment.rb			  
│	│	├─	youtube_data_api.rb			  
│	│	└─	version.rb					  
│	└─	ytvarb.rb						  
├─	/log								  
├─	/spec								  
├─	LICENSE								  
└─	README.md							  
```
