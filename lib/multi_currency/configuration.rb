module MultiCurrency
  class Configuration
    attr_accessor :default_currency

    def initialize
      @default_currency = 'usd'
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure MultiCurrency someplace sensible,
  # like config/initializers/multi_currency.rb
  #
  # @example
  #   MultiCurrency.configure do |config|
  #     config.default_currency = 'usd'
  #   end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end