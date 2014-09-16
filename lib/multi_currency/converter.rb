module MultiCurrency
  def self.convert(source_amount, source_currency, to_currency, exchange_date = Date.today)
    rate = MultiCurrency.configuration.default_converter.get_rate_and_cache(source_currency, to_currency, exchange_date)
    source_amount * rate
  end
end