require "multi_currency/version"
require "multi_currency/converter"

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
          date = self.send("#{column}_rate_date") rescue Date.today
          rate = MultiCurrency::Converter.get_rate_and_cache(default_currency, currency_code, date)
          self.send(column) * rate
        end
      end
    end
  end
end

ActiveRecord::Base.include(MultiCurrency)