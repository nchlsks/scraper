class Worker < BaseWorker
  attr_reader :report
  attr_accessor :num_threads, :mode, :allowed_retries, :timeout

  def initialize(num_threads:, mode:, allowed_retries:, timeout:)
    @mode            = mode
    @num_threads     = num_threads || 1
    @allowed_retries = allowed_retries || 3
    @timeout         = timeout

    super
  end

  def run(source:)
    processing {
      table = Provider.new(mode: mode, source: source).list
      table.each do |url|
        retry_count = 1

        queue << [url, retry_count]
      end

      run_threads {
        url, retry_count = queue.pop(non_block=true)
        responce(url, retry_count)
      }
    }
  end

  def responce(url, retry_count=1)
    return if report.has_key?(url) && retry_count > allowed_retries
    
    site = Site.new(url: url)
    site.get_response
    site.save if site.success?

    @semaphore.synchronize { report[url] = site.response&.code || :error }
    responce(url, retry_count + 1) if site.failed?
  ensure
    save_map(url)
  end

  def print_report
    codes = report.values.group_by {_1}.transform_values { _1.count }

    %|
    Done
    URI processed: #{report.keys.size}
    Response codes: \n#{codes.map { |a, b| "- #{a}: #{b}\n" }.join}
    |
  end

  def save_report
    save_index(
      uri_processed: report.keys.size,
      codes: report.values.group_by { _1 }.transform_values { _1.count }
    )
  end
end