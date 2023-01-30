class Cache
  attr_reader :page
  attr_accessor :title

  PATH = 'cache'

  def initialize(title)
    @page = PStore.new("#{PATH}/#{title}.pstore")
  end

  def save(**hash)
    page.transaction do
      hash.each { |k,v|
        page[k] = v
      }
    end
  end

  def delete(table)
    page.transaction { page.delete(table) }
  end

  def delete_all
    page.transaction { 
      page.roots.each { page.delete(_1) }
    }
  end

  def read
    page.transaction(true) { yield(page) }
  end
end