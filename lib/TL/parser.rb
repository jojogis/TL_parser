# frozen_string_literal: true

require_relative "parser/version"
require_relative "offer"
require "open-uri"
require "nokogiri"
require "json"

# main module of gem
module TL
  # parses page and loads offers from TL widget
  module Parser
    LOGIN_KEY = "TL-INT-"
    OFFERS_BASE_URL = "https://ibe.tlintegration.com/ApiWebDistribution/BookingForm"

    class Error < StandardError; end

    class << self
      def load_offers(url, opts = {})
        start_date = opts.fetch(:start_date, Date.today)
        finish_date = opts.fetch(:finish_date, Date.today.next_day)
        adults_count = opts.fetch(:adults_count, 2)
        children_ages = opts.fetch(:children_ages, [])
        format = opts.fetch(:format, :hash)

        doc = load_page(url)
        login = get_login(doc)
        hotel_id = get_hotel_id(login)
        offers_link = generate_offers_link(hotel_id, start_date, finish_date, adults_count, children_ages)
        offers = get_js(offers_link)
        return nil unless check_response(offers) #TODO сообщения об ошибке

        hotel_info = get_js(generate_hotel_link(hotel_id))
        return nil unless check_response(hotel_info)

        if format == :hash
          JSON.parse(offers.body).merge(JSON.parse(hotel_info.body))
        elsif format == :objects
          TL::Offer.from_hash_collection(JSON.parse(offers.body), JSON.parse(hotel_info.body))
        end
      end

      private

      def check_response(response)
        [Net::HTTPSuccess, Net::HTTPFound, Net::HTTPOK].include?(response.class)
      end

      def generate_hotel_link(hotel_id)
        "#{OFFERS_BASE_URL}/hotel_info?include_rates=true&include_transfers=true?language=ru-ru&hotels[0].code=#{hotel_id}"
      end

      def generate_offers_link(hotel_id, start_date, finish_date, adults_count, children_ages)
        offers_link = "#{OFFERS_BASE_URL}/hotel_availability?include_rates=true&include_transfers=true"
        offers_link += "&include_all_placements=true&include_promo_restricted=true&language=ru-ru"
        offers_link += "&criterions[0].hotels[0].code=#{hotel_id}"
        offers_link += "&criterions[0].dates=#{start_date.strftime("%Y-%m-%d")};#{finish_date.strftime("%Y-%m-%d")}"
        offers_link += "&criterions[0].adults=#{adults_count}"
        offers_link + "&criterions[0].children=#{children_ages.join(";")}"
      end

      def get_hotel_id(login)
        response = get_js("https://ibe.tlintegration.com/integration/profiles/TL-INT-#{login}.js")
        return nil unless check_response(response)

        script = response.body
        login_start = script.index("providers") + 14
        login_end = script.index(",", login_start) - 2
        script.slice(login_start..login_end)
      end

      def get_login(doc)
        script = doc.css("script").find { |tag| tag.inner_html.include?(LOGIN_KEY) }&.inner_html
        return nil if script.nil? #TODO ошибки

        login_start = script.index(LOGIN_KEY) + LOGIN_KEY.length
        login_end = script.index("'", login_start) - 1
        script.slice(login_start..login_end)
      end

      def load_page(url)
        html = URI.parse(url).open
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
