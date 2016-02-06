# lita-book

show book information

## Installation

Add lita-book to your Lita instance's Gemfile:

``` ruby
gem "lita-book"
```

## Configuration

### Required attributes

*`rakutenId` (String) - 楽天アプリID

### Example

``` ruby
Lita.configure do |config|
  config.robot.adapter = :slack
  config.handlers.book.rakutenId = "1234567890"
end
```

## Usage

    book: <book_title>

## License

[MIT](http://opensource.org/licenses/MIT)
