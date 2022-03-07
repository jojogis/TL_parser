# frozen_string_literal: true

require "date"

RSpec.describe TL::Parser do
  it "has a version number" do
    expect(TL::Parser::VERSION).not_to be nil
  end

  it "can get offers from sanpriboy" do
    result = TL::Parser.load_offers(url: "https://sanpriboy.ru/",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
  end

  it "can get offers from admiral-klub" do
    result = TL::Parser.load_offers(url: "https://admiral-klub.ru",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
  end
end
