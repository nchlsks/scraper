## General info
This project is simple web scraper that takes a list of URLs and retrieves the HTML content of each page.

<img src="/doc/render1675524398730.gif?raw=true"/>

## Table of contents
- [General info](#general-info)
- [Table of contents](#table-of-contents)
- [Technologies](#technologies)
- [Setup](#setup)
- [Scraping:](#scraping)
  - [Options](#options)
  - [Run](#run)
  - [Log](#log)
  - [Report](#report)
  - [IRB](#irb)
	
## Technologies
Project is created with:
* ruby 3.0.1p64 (2021-04-05 revision 0fb782ee38)
* Bundler version 2.2.15
* gem version 3.2.15

The scraper is implemented in ruby with minimal use of gems. Additional Gems:
  * thor (1.2.1)
  * require_all (3.0.0)
  * dotenv (2.8.1)
  * pry (0.14.2)
  
## Setup
To run this project, install it locally and run `bundle install`:

```
$ cd scraper
$ bundle install
$ ruby ./main.rb crawler --file_path "list.csv" --num_threads 10
```

## Scraping:
The simplest way to use is by calling `ruby ./main.rb` at the project root directory. You will see a list of available commands. It works like a rake gem in rails:
```
  main.rb crawler --file-path=FILE_PATH  # Simple web crawler in Ruby
  main.rb get_site --url=URL             # Get body from cache
  main.rb last_crawler                   # The last result of the crawler
  main.rb load_map                       # Cache of the crawler
  main.rb clear_cache                    # Clear cache
  main.rb help [COMMAND]                 # Describe available commands or one specific command
```

To scan sites, you need to fill in the list.csv file and specify the path to it in the `--file-path` attribute. For example:
```
$ ruby ./main.rb crawler --file_path "list.csv"
```
### Options
List of crawler options:
| Attr                | Type      | Required | Default | Example |
| -----------         | --------- | -------- | ------- | ------- |
| `--file_path`       | String    | Yes      |         | list.csv
| `--timeout`         | Numeric   | No       |         | 100
| `--allowed_retries` | Numeric   | No       | 3       | 3
| `--num_threads`     | Numeric   | No       | 1       | 10
| `--delay`           | Numeric   | No       |         | 0.5

### Run
```
$ ruby ./main.rb crawler --file_path "list.csv" --timeout 100 --allowed_retries 3 --num_threads 10
```

### Log
After running the crawler, let's use the `tail -f log/process.log` just for the sake of fun of seeing the process as they happen. And this is the output you should see at your terminal:

```
I, [2023-01-31T01:52:04.137164 #26155] INFO -- : Run worker! PID: 26155
I, [2023-01-31T01:52:04.497718 #26155] INFO -- : https://rubydoc.info/: Net::HTTPOK, 200, OK
I, [2023-01-31T01:52:04.960279 #26155] INFO -- : https://www.rubycentral.com: Net::HTTPMovedPermanently, 301, Moved Permanently
...
E, [2023-01-31T01:53:04.175099 #26155] ERROR -- : https://test.com: execution expired
W, [2023-01-31T02:07:49.501383 #26473] WARN -- : Execution expired, 25s (Timeout::Error)!
```

### Report
After the scan is completed, you will see a report:
```
Done
URI processed: 9
Response codes:

- 200: 7
- 301: 1
- error: 1
```

To get a list of crawled sites, run `ruby ./main.rb load_map`:
```
https://rubydoc.info/
https://guides.rubyonrails.org/
https://www.rubycentral.com
https://ruby-doc.org/
https://www.google.com
...
```

To find out the last run of the scanner, call `ruby ./main.rb last_crawler`
```
    Report created at: 2023-01-30 23:39:00 +0200
    URI processed: 8
    Response codes:

- 200: 7
- 301: 1
```

To view the saved result for a specific site, call the command `ruby ./main.rb get_site --url https://slashdot.org`
```
<!-- html-header type=current begin -->

    <!DOCTYPE html>


    <html lang="en">
    <head>
    <!-- Render IE9 -->

.....
```

### IRB
if you want to use interactive ruby shell(irb) and enable additional site sources mode (Array):

```
$ bundle exec irb
> require_relative 'config/environment.rb'

> w = Worker.new(mode: :array, num_threads: 10, allowed_retries: 3, timeout: 10)
> w.run(source: ["https://guides.rubyonrails.org/", "https://discuss.rubyonrails.org/"])

> w.report
> => {"https://guides.rubyonrails.org/"=>"200", "https://discuss.rubyonrails.org/"=>"200"}

> w.load_last_index
> =>
  { :uri_processed=>8,
  :codes=>{"200"=>7, "301"=>1},
  :created_at=>2023-01-30 23:39:00.057268 +0200 }

> s = w.site("https://guides.rubyonrails.org/")
> => #<Site:0x00007fe18d854bb8

> s.body
> => "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n <meta charset=\"utf-8\">\n <meta name=\"viewport\" content=\"width=device-width ...
```
