class Site < Base
  attr_reader :uri, :response, :state
  attr_accessor :url

  def initialize(url:)
    @url = url
    @uri = URI(url)
  end

  def scheme
    uri.scheme
  end

  def host
    uri.host
  end

  def body
    response.body
  end

  def code
    response.code
  end

  def get_response
    @response = Net::HTTP.get_response(uri)
    @state = :success
  rescue => e
    @state = :failed
  ensure
    info("#{url}: #{response.code_type.name}, #{response.code}, #{response.message}") if success?
    error("#{url}: #{e}") if failed?
  end

  def success?
    state == :success
  end

  def failed?
    state == :failed
  end

  def save
    cache = Cache.new(host)
    cache.save(url => self, 'last_revision' => Time.now)
  end

  def load
    cache = Cache.new(host)
    cache.read { |table| table[url] }
  end
end