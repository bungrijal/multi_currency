# MultiCurrency

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'multi_currency', github: 'xsoulsyndicate/multi_currency'

And then execute:

    $ bundle

## Usage

NOTE: Still in development

For example you already had 'price' attribute in Product model and want to add multi currency support for it.

```ruby
class Product < ActiveRecord::Base
  attr_accessible :price, :price_rate_date, :price_currency, :price_source_amount, :price_source_currency # For Rails 3

  multi_currency_for [:price]

  before_save :do_currency_exchange
end
```

Add required migration. Create a migration and add this columns:

```ruby
add_column :products, :price_rate_date, :date
add_column :products, :price_currency, :string
add_column :products, :price_source_amount, :decimal
add_column :products, :price_source_currency, :string
```

All columns are prefixed with :price in this case. Adjust the prefix according to the column name.

So when you save a product, you can just do it like this.

```ruby
product = Product.new(price_source_amount: 100, price_source_currency: 'USD')
product.save
```

The required attributes to set is only _source_currency and _source_amount. You can set _rate_date if you want to specify in which date the currency exchange rate will be fetched.

After that you can get price in any currency:

```ruby
product = Product.first
product.price_in('EUR')
```

Default exchange rate is rate from _rate_date column. If you want to get price with currency exchange rate in other date, just pass a date:

```ruby
product.price_in('EUR', Date.yesterday)
```

You can also get total of price in other currency:

```ruby
Product.sum_price('EUR', Date.today)
```

## Configuration

Add an initializer e.g config/initializers/multi_currency.rb

```ruby
MultiCurrency.configure do |config|
  config.default_currency = 'eur'
end
```

## Open Exchange Rates Converter

Set default_converter = 'Openexchange' on config/initializers/multi_currency.rb

```ruby
MultiCurrency.configure do |config|
  config.default_converter = 'Openexchange'
end
```

You will need APP ID to use OpenExchangeRate, you can get from https://openexchangerates.org for free.
Set OPEN_EXCHANGE_RATES_APP_ID environment variable. 

```ruby
OPEN_EXCHANGE_RATES_APP_ID = 'APP_ID'
```

## Contributing

1. Fork it ( http://github.com/xsoulsyndicate/multi_currency/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
