module Logging
  def logger
    Logger.new('log/process.log')
  end

  def info(message)
    logger.add(Logger::INFO, message)
  end

  def error(message)
    logger.add(Logger::ERROR, message)
  end

  def warn(message)
    logger.add(Logger::WARN, message)
  end
end