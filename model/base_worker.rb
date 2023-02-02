class BaseWorker < Base
  attr_accessor :timeout

  def initialize(*)
    init_options
  end

  def run
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def stop!
    threads = Thread.list.select { _1.stop? }

    threads.each(&:exit)
    threads.clear

    queue.close
    logger.close
  end

  def save_index(**hash)
    cache = Cache.new('index')
    time_now   = Time.now
    time_stamp = time_now.to_i

    cache.save(
      time_stamp => { 
        **hash,
        created_at: time_now
      }
    )
  end

  def save_map(url)
    cache = Cache.new('map')
    time_now   = Time.now

    cache.save(
      url => { 
        created_at: time_now
      }
    )
  end

  def load_all_index
    read_index { |t| t.roots }
  end

  def get_last_index
    load_all_index.last
  end

  def load_last_index
    read_index { |t| t[get_last_index] }
  end

  def load_map
    read_map { |t| t.roots }
  end

  def site(url)
    site = Site.new(url: url)
    site.load
  end

  def clear_cache
    dir_path = Cache::PATH
    FileUtils.rm_rf Dir.glob("#{dir_path}/*") if File.exist?(dir_path)
  end

  private
  attr_reader :threads, :queue, :repeat, :passage

  def init_options
    @queue  = Thread::Queue.new
    @repeat = Thread::Queue.new
    @semaphore = Mutex.new
    @report  = {}
    @passage = {}
    @threads = []
  end

  def processing
    if timeout.nil?
      yield
    else
      around_timeout { yield }
    end
  end

  def around_timeout
    Timeout::timeout(timeout) {
      info("Run worker! PID: #{Process.pid}")
      yield
    }
  rescue Timeout::Error
    warn("Execution expired, #{timeout}s (Timeout::Error)!")
    stop!
  end

  def run_threads
    num_threads.times do |i|
      threads << Thread.new do
        until queue.empty?
          yield
        end
      rescue ThreadError
      rescue => e
        error("Error msg: #{e}")
      end
    end

    threads.each { |thr| thr.join }
  end

  def read_index
    cache = Cache.new('index')
    cache.read { |t| yield(t) }
  end

  def read_map
    cache = Cache.new('map')
    cache.read { |t| yield(t) }
  end
end