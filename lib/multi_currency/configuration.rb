module MultiCurrency
  class Configuration
    attr_accessor :default_currency, :default_converter

    def initialize
      @default_currency = 'usd'
      @default_converter = 'GrandTrunk'
    end

    def default_converter
      "MultiCurrency::Converter::#{@default_converter}".safe_constantize
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