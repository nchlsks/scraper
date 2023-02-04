require_relative 'config/environment.rb'

class Main < Thor
  desc 'crawler', 'Simple web crawler in Ruby'
  option :file_path, type: :string, required: true
  option :timeout, type: :numeric
  option :allowed_retries, type: :numeric
  option :num_threads, type: :numeric
  option :delay, type: :numeric

  def crawler
    file_path = options[:file_path]
    allowed_retries = options[:allowed_retries]
    timeout = options[:timeout]
    num_threads = options[:num_threads]
    delay = options[:delay]

    processing

    worker = Worker.new(
      mode: :file,
      num_threads: num_threads,
      allowed_retries: allowed_retries,
      timeout: timeout,
      delay: delay
    )

    worker.run(source: file_path)
  ensure
    worker.save_report
    puts worker.print_report
  end

  desc 'last_crawler', 'The last result of the crawler'
  def last_crawler
    index = BaseWorker.new.load_last_index
    
    puts %(
    Report created at: #{index[:created_at]}
    URI processed: #{index[:uri_processed]}
    Response codes: \n#{index[:codes].map { |a, b| "- #{a}: #{b}\n" }.join}
    )
  end

  desc 'load_map', 'Cache of the crawler'
  def load_map
    puts BaseWorker.new.load_map
  end

  desc 'get_site', 'Get body from cache'
  option :url, type: :string, required: true

  def get_site
    site = BaseWorker.new.site(options[:url])
    puts site&.body 
  end

  desc 'clear_cache', 'Clear cache'
  def clear_cache
    puts BaseWorker.new.clear_cache
  end

  private

  def processing
    spinner = Enumerator.new do |e|
      loop do
        e.yield '|'
        e.yield '/'
        e.yield '-'
        e.yield '\\'
      end
    end

    Thread.new do
      loop do
        printf("\rProcessing: %s", spinner.next)
        sleep(0.1)
      end
    end
  end
end

Main.start(ARGV)