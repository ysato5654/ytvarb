# ytvarb

Ruby library for YouTube Video Analytics

## Installation

```rb
under construction
```

## Preparation before using

Before using ytvarb, you need to get API key in order to access YouTube Data API v3.

1. Get your API key
2. Create 'api_key.txt' file into config/ directory
3. Write your API key in the file

## Usage

```rb
under construction
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
