# frozen_string_literal: true

require "date"

RSpec.describe TL::Parser do
  it "has a version number" do
    expect(TL::Parser::VERSION).not_to be nil
  end

  it "can get offers from sanpriboy" do
    result = TL::Parser.load_offers("https://sanpriboy.ru",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month.next_day)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
    expect(result).to have_key("transfers")
    expect(result).to have_key("services")
    expect(result).to have_key("availability_result")
    expect(result).to have_key("room_type_quotas")
  end

  it "can get offers from admiral-klub" do
    result = TL::Parser.load_offers("https://admiral-klub.ru",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month.next_day)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
    expect(result).to have_key("transfers")
    expect(result).to have_key("services")
    expect(result).to have_key("availability_result")
    expect(result).to have_key("room_type_quotas")
  end

  it "can get offers from dona-rosa" do
    result = TL::Parser.load_offers("https://dona-rosa.ru",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month.next_day)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
    expect(result).to have_key("transfers")
    expect(result).to have_key("services")
    expect(result).to have_key("availability_result")
    expect(result).to have_key("room_type_quotas")
  end

  it "can get offers from ghkandt" do
    result = TL::Parser.load_offers("https://ghkandt.com/",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month.next_day)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("room_stays")
    expect(result).to have_key("transfers")
    expect(result).to have_key("services")
    expect(result).to have_key("availability_result")
    expect(result).to have_key("room_type_quotas")
  end

  it "it returns warning when input nights is zero" do
    result = TL::Parser.load_offers("https://admiral-klub.ru",
                                    start_date: Date.today.next_month,
                                    finish_date: Date.today.next_month)
    expect(result).to be_a_kind_of(Hash)
    expect(result).to have_key("warnings")
    expect(result["warnings"]).to be_a_kind_of(Array)
    expect(result["warnings"]).not_to be_empty
    expect(result["warnings"].first["message"]).to eql("Nights must be greater than zero")
  end
end
