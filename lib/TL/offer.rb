# frozen_string_literal: true

# main module of gem
module TL

  # represents offer
  class Offer
    def initialize(price:, capacity:, room_name:, room_description:, rate_plan_name:)
      @price = price
      @capacity = capacity
      @room_name = room_name
      @room_description = room_description
      @rate_plan_name = rate_plan_name
    end
    class << self
      def from_hash_collection(offers_hash, hotel_info)
        result = []
        offers_hash.dig("room_stays").each do |offer_hash|
          rate_plan_code = offer_hash.dig("rate_plans").first.dig("code")
          rate_plan_name = find_rate_plan(hotel_info, rate_plan_code).dig("name")
          offer_hash.dig("room_types").each do |room_type|
            room = find_room_type(hotel_info, room_type.dig("code"))
            room_type.dig("placements").each do |placement|
              price = placement.dig("price_after_tax")
              capacity = placement.dig("capacity")
              room_name = room.dig("name")
              room_description = room.dig("description")

              result << Offer.new(price: price,
                                  capacity: capacity,
                                  room_name: room_name,
                                  room_description: room_description,
                                  rate_plan_name: rate_plan_name)
            end
          end
        end
        result
      end

      private

      def find_rate_plan(hotel_info, rate_plan_code)
        hotel_info.dig("hotels").first.dig("rate_plans").find { |rate_plans| rate_plans.dig("code") == rate_plan_code }
      end

      def find_room_type(hotel_info, room_code)
        hotel_info.dig("hotels").first.dig("room_types").find { |room_type| room_type.dig("code") == room_code }
      end
    end
  end
end
