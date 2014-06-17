require "multi_currency/version"
require "multi_currency/configuration"
require "converter/grand_trunk"

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
        define_singleton_method "sum_#{column}" do |currency, date = Date.today|
          formatted_date = date.strftime("%Y-%m-%d")
          self.sum("
            CASE #{column}_currency
              WHEN '#{currency.downcase}' THEN #{column}
              ELSE #{column} * (SELECT exchange_rates.rate FROM exchange_rates WHERE (exchange_rates.from_code = #{column}_currency AND to_code = '#{currency.downcase}' AND date = '#{formatted_date}') )
            END")
        end

        define_method "#{column}_in" do |currency_code, date = Date.today|
          default_currency = self.send("#{column}_currency") rescue MultiCurrency.configuration.default_currency
          rate = MultiCurrency.configuration.default_converter.get_rate_and_cache(default_currency, currency_code, date)
          self.send(column) * rate
        end
      end

      define_method "do_currency_exchange" do
        multi_currency_columns.each do |column|
          eval("self.#{column}_currency = '#{MultiCurrency.configuration.default_currency.downcase}'")
          date = self.send("#{column}_rate_date") || Date.today
          eval("self.#{column}_rate_date = date")
          rate = MultiCurrency.configuration.default_converter.
            get_rate_and_cache(self.send("#{column}_source_currency"), self.send("#{column}_currency"), date)
          eval("self.#{column} = self.#{column}_source_amount * rate")
        end
      end

    end
  
  end
end

ActiveRecord::Base.send(:include, MultiCurrency)