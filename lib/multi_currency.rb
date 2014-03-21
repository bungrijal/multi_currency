require "multi_currency/version"

module MultiCurrency
  extend ActiveSupport::Concern

  module ClassMethods
    def multi_currency_columns
      @@multi_currency_columns ||= []
    end

    def multi_currency_columns=(columns)
      if columns.is_a? Array
        @@multi_currency_columns = columns
      else
        raise "Multi currency columns should be an array"
      end
    end

    def multi_currency_for(columns)
      multi_currency_columns = columns
      multi_currency_columns.each do |column|
        define_singleton_method "sum_#{column}" do |currency|
          self.sum("
            CASE #{column}_currency
              WHEN '#{currency.downcase}' THEN #{column}
              ELSE #{column} * (SELECT exchange_rates.rate FROM exchange_rates WHERE (exchange_rates.from_code = #{column}_currency AND to_code = '#{currency.downcase}' AND date = #{column}_rate_date) )
            END")
        end

        define_method "#{column}_in" do |currency_code|
          default_currency = self.send("#{column}_currency") rescue Money.default_currency.id
          if default_currency.downcase == currency_code.downcase
            rate = 1.0
          else
            date = self.send("#{column}_rate_date") rescue Date.today
            exchange_rate = ExchangeRate.find_by_from_code_and_to_code_and_date(default_currency.downcase, currency_code.downcase, date)
            rate = if exchange_rate.present?
              exchange_rate.rate
            else
              response = Net::HTTP.get_response(URI("http://currencies.apps.grandtrunk.net/getrate/#{date.strftime("%Y-%m-%d")}/#{default_currency.downcase}/#{currency_code.downcase}"))
              if response.is_a? Net::HTTPOK
                ExchangeRate.create(from_code: default_currency, to_code: currency_code, date: date, rate: response.body.to_f)
                response.body.to_f
              else
                raise "#{response.code}: #{response.body}"
              end
            end
          end
          self.send(column) * rate
        end
      end
    end
  end
end

ActiveRecord::Base.include(MultiCurrency)