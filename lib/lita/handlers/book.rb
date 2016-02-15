require 'net/http'
require "addressable/uri"
require 'json'
require 'open-uri'

module Lita
  module Handlers
    class Book < Handler
      config :rakutenId

      route(/^book:\s+(.+).*$/, :book, help: {"book: BOOK_TITLE" => "Return book information"})

      def book(response)
        url = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20130522?format=json&title="
        url << response.matches[0][0]
        url << "&applicationId=" << config.rakutenId

        uri = Addressable::URI.parse(url)
        json = Net::HTTP.get(uri)
        res = JSON.parse(json)

        if res["count"] == 0 then
          response.reply("見つかりませんでした")
        else
          r = res["Items"][0]["Item"]

          target = response.room
          text = "#{r['author']} 著\n#{r['itemCaption']}"
          attachment = Lita::Adapters::Slack::Attachment.new(
            text, {
              title: "#{r['title']} (#{r['publisherName']}) - #{r['salesDate']}",
              text: text,
              fields: [
                {
                  title: "Amazon.co.jp",
                  value: "￥ #{r['itemPrice']}\n#{amazon(isbn10(r['isbn']))}",
                  short: false
                }
              ],
              thumb_url: "#{r['largeImageUrl']}"
            }
          )
          robot.chat_service.send_attachment(target, attachment)
        end

      rescue => e
        response.reply("#{e.backtrace}\n #{e.message}")
      end

      def isbn10(isbn13)
        isbn10 = isbn13.slice(3..11)
        a = isbn10.scan(/.{1,1}/).map.with_index { |item, i| item.to_i * (10 - i) }.inject(:+)
        b = 11 - a % 11
        if b == 11
          isbn10 + "0"
        elsif b == 10
          isbn10 + "x"
        else
          isbn10 + b.to_s
        end
      end

      def amazon(isbn)
        url = "http://www.amazon.co.jp/dp/#{isbn}"
        if open(url).status[0] == "200" then url
        else ""
        end
      end

      Lita.register_handler(self)
    end
  end
end
