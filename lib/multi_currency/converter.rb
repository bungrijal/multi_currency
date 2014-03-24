module MultiCurrency
  module Converter
    
    def get_rate_and_cache(source_currency, to_currency, date)
      if source_currency.downcase == to_currency.downcase
        rate = 1.0
      else
        exchange_rate = ExchangeRate.find_by_from_code_and_to_code_and_date(source_currency.downcase, to_currency.downcase, date)
        rate = if exchange_rate.present?
          exchange_rate.rate
        else
          response = Net::HTTP.get_response(URI("http://currencies.apps.grandtrunk.net/getrate/#{date.strftime("%Y-%m-%d")}/#{source_currency.downcase}/#{to_currency.downcase}"))
          if response.is_a? Net::HTTPOK
            ExchangeRate.create(from_code: source_currency, to_code: to_currency, date: date, rate: response.body.to_f)
            response.body.to_f
          else
            raise "#{response.code}: #{response.body}"
          end
        end
      end
      rate
    end
  
  end
end