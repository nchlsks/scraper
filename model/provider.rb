class Provider
  attr_accessor :mode, :source

  def initialize(mode:, source:)
    @mode = mode
    @source = source
  end

  def list
    case mode
    when :file
      raise FileNotFound unless File.exist?(source)

      table = CSV.parse(File.read(source), headers: true)
      table.map { _1['URI'] }
    when :array
      raise ArrayNotFound unless source.is_a?(Array)
      source
    else
      raise ModeNotSupported
    end
  end

  class FileNotFound < StandardError;end
  class ArrayNotFound < StandardError;end
  class ModeNotSupported < StandardError;end
end