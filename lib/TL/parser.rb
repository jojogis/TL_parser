# frozen_string_literal: true

require_relative "parser/version"
require 'open-uri'
require 'nokogiri'
require 'json'

module TL
  module Parser

    LOGIN_KEY = 'TL-INT-'

    class Error < StandardError; end

    class << self
      def load_offers(url:, start_date: Date.today, finish_date: Date.tomorrow, adults_count: 2, children_ages: [])
        doc = load_page(url)
        login = get_login(doc)
        hotel_id = get_hotel_id(login)
        offers_link = "https://ibe.tlintegration.com/ApiWebDistribution/BookingForm/hotel_availability?include_rates=true"
        offers_link += "&include_transfers=true&include_all_placements=true&include_promo_restricted=true&language=ru-ru"
        offers_link += "&criterions[0].hotels[0].code=#{hotel_id}"
        offers_link += "&criterions[0].dates=#{start_date.strftime("%Y-%m-%d")};#{finish_date.strftime("%Y-%m-%d")}&criterions[0].adults=#{adults_count}"
        response = get_js(offers_link)
        return nil unless [Net::HTTPSuccess, Net::HTTPFound, Net::HTTPOK].include?(response.class)
        JSON.parse(response.body)
      end

      private
        def get_hotel_id(login)
          response = get_js("https://ibe.tlintegration.com/integration/profiles/TL-INT-#{login}.js")
          return nil unless [Net::HTTPSuccess, Net::HTTPFound, Net::HTTPOK].include?(response.class)
          script = response.body
          login_start = script.index('providers') + 14
          login_end = script.index(',', login_start) - 2
          script.slice(login_start..login_end)
        end

        def get_login(doc)
          script = doc.css('script').find { |tag| tag.inner_html.include?(LOGIN_KEY) }.inner_html
          login_start = script.index(LOGIN_KEY) + LOGIN_KEY.length
          login_end = script.index("'", login_start) - 1
          script.slice(login_start..login_end)
        end

        def load_page(url)
          html = URI.open(url)
          ::Nokogiri::HTML(html)
        end

        def get_js(url)
          uri = URI(url)
          request = Net::HTTP::Get.new(uri)
          response = nil
          Net::HTTP.start(uri.hostname, use_ssl: true) do |connection|
            response = connection.request(request)
          end
          response
        end
    end
  end
end
