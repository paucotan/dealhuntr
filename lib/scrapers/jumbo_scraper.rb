require File.expand_path('config/environment', Dir.pwd)
require 'selenium-webdriver'
require 'nokogiri'
require 'active_record'
require_relative '../../app/models/store'
require_relative '../../app/models/product'
require_relative '../../app/models/deal'
module Scrapers
  class JumboScraper
    JUMBO_DEALS_URL = 'https://www.jumbo.com/aanbiedingen/nu'.freeze
    CATEGORY_SELECTOR = 'section.category-section'.freeze
    CATEGORY_NAME_SELECTOR = 'h4.jum-heading.h4.category-heading strong'.freeze
    DEAL_CARD_GRID_SELECTOR = 'div.jum-card-grid'.freeze
    DEAL_CARD_SELECTOR = '.jum-card.card-promotion'.freeze
    EXPIRY_DATE_SELECTOR = 'p.subtitle'.freeze
    TARGET_IMAGE_SELECTOR = 'div.card-image img'.freeze
    TITLE_SELECTOR = 'h3.jum-heading.bold.h6.title'.freeze
    DEAL_TYPE_SELECTOR = '.jum-tag .lower'.freeze
    SUBTITLE_SELECTOR = 'p.subtitle'.freeze

    CATEGORY_MAPPING = {
      "Aardappelen, groente en fruit" => "Fruits & Vegetables",
      "Verse maaltijden en gemak" => "Ready Meals",
      "Vlees, vis en vega" => "Meat & Fish",
      "Brood en gebak" => "Bakery",
      "Vleeswaren, kaas en tapas" => "Deli",
      "Zuivel, eieren, boter" => "Dairy & Eggs",
      "Conserven, soepen, sauzen, oliën" => "Canned Goods & Condiments",
      "Wereldkeukens, kruiden, pasta en rijst" => "Pasta, Rice & International",
      "Ontbijt, broodbeleg en bakproducten" => "Breakfast & Spreads",
      "Koek, snoep, chocolade en chips" => "Snacks & Sweets",
      "Koffie en thee" => "Coffee & Tea",
      "Frisdrank en sappen" => "Beverages",
      "Bier en wijn" => "Alcohol",
      "Drogisterij en baby" => "Drugstore",
      "Huishouden en dieren" => "Household",
      "Non-food en servicebalie" => "Non-Food"
    }.freeze

    def initialize
      @driver = Selenium::WebDriver.for :chrome
      @driver.manage.timeouts.implicit_wait = 10
    end

    def scrape
      begin
        puts "Opening #{JUMBO_DEALS_URL}..."
        @driver.get(JUMBO_DEALS_URL)
        puts "Scrolling to load all deals..."
        10.times do |i|
          @driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
          sleep 3
        end

        html = @driver.page_source
        File.write("jumbo_debug.html", html) # For debugging
        doc = Nokogiri::HTML(html)
        page_expiry_text = doc.at_css('p.description')&.text
        puts "Page expiry text: #{page_expiry_text.inspect}"
        page_expiry = page_expiry_text&.match(/Tot en met \w+ (\d+ \w+)/)&.captures&.first
        default_expiry = page_expiry ? parse_date(nil, "di #{page_expiry}") : Date.today + 7 # Fallback to 1 week if parsing fails

        all_deals = doc.css(DEAL_CARD_SELECTOR)
        puts "Total deal cards found: #{all_deals.count}"

        processed = 0
        skipped = 0
        all_deals.each_with_index do |deal, deal_index|
          expiry_date = deal.at_css(EXPIRY_DATE_SELECTOR)&.text&.strip
          category_name = deal.ancestors('section.category-section').first&.at_css(CATEGORY_NAME_SELECTOR)&.text&.strip || "Uncategorized"
          process_deal(deal, expiry_date, deal_index, category_name, default_expiry) ? processed += 1 : skipped += 1
        end

        puts "Processed: #{processed}, Skipped: #{skipped}"
        puts "Scraping done!"
      rescue StandardError => e
        puts "Error: #{e.message}"
        puts e.backtrace.join("\n")
      ensure
        @driver.quit
      end
    end

    private

    def process_deal(deal, expiry_date, index, category_name, default_expiry)
      deal_data = extract_deal_data(deal, index)
      return false if deal_data.nil?

      store = save_store
      return false unless store

      product = save_product(deal_data)
      return false unless product

      parsed_expiry_date = parse_date(deal, expiry_date) || default_expiry
      save_deal(deal_data, store, product, parsed_expiry_date, index, category_name)
      log_deal(deal_data, index, expiry_date, category_name)
      true
    end

    def extract_deal_data(deal, index)
      name = deal.at_css(TITLE_SELECTOR)&.text&.strip || 'No name'
      puts "Extracted name: #{name} from deal ##{index + 1}"
      subtitle = deal.at_css(SUBTITLE_SELECTOR)&.text&.strip || 'No subtitle'

      deal_type_element = deal.at_css('.jum-tag .lower') || deal.at_css('.jum-tag') || deal.at_css('.tag')
      deal_type_text = deal_type_element&.text&.strip || 'No deal type'
      puts "Extracted deal type text: #{deal_type_text} from deal ##{index + 1}"
      if deal_type_text == 'No deal type'
        puts "Debug: Raw HTML for deal ##{index + 1}: #{deal.to_html}"
      end

      deal_url = deal.at_css('h3.title a')&.[]('href')
      deal_url = "https://www.jumbo.com#{deal_url}" if deal_url && !deal_url.start_with?('http')

      regular_price = nil
      discounted_price = nil

      if deal_type_text.present? && deal_type_text.match?(/(\d+)\s*(?:voor|for)\s*€?([\d,.]+)/i)
        match = deal_type_text.match(/(\d+)\s*(?:voor|for)\s*€?([\d,.]+)/i)
        quantity = match[1].to_i
        total_price = match[2].gsub(',', '.').to_f
        discounted_price = total_price
        regular_price = (total_price / 0.75).round(2) if total_price > 0
      elsif deal_type_text.present?
        case deal_type_text.downcase
        when /2\+1 gratis/i
          discounted_price = nil
        when /([\d.]+)% korting/i
          discounted_price = nil
        end
      end

      image_url = extract_image_url(deal, index)

      regular_price_display = regular_price.nil? ? 'N/A' : regular_price

      {
        name: name,
        description: subtitle,
        regular_price: regular_price,
        regular_price_display: regular_price_display,
        discounted_price: discounted_price,
        deal_type: deal_type_text,
        image_url: image_url,
        deal_url: deal_url
      }
    end

    def extract_image_url(deal, index)
      image_element = deal.at_css(TARGET_IMAGE_SELECTOR)
      return 'No image' unless image_element

      temp_image_url = image_element['src']
      unless temp_image_url.match?(/data:image\/gif;base64/)
        return temp_image_url
      end

      begin
        @driver.execute_script("arguments[0].scrollIntoView(true);", @driver.find_element(:css, "#{DEAL_CARD_SELECTOR}:nth-child(#{index + 1}) #{TARGET_IMAGE_SELECTOR}"))
        wait = Selenium::WebDriver::Wait.new(timeout: 5)
        wait.until do
          src = @driver.find_element(:css, "#{DEAL_CARD_SELECTOR}:nth-child(#{index + 1}) #{TARGET_IMAGE_SELECTOR}")['src']
          src unless src.match?(/data:image\/gif;base64/)
        end || 'No image'
      rescue Selenium::WebDriver::Error::TimeoutError
        puts "Timeout waiting for image to load for Deal ##{index + 1}, using placeholder: #{temp_image_url}"
        'No image'
      end
    end

    def save_store
      store = Store.find_or_create_by!(name: 'Jumbo') do |s|
        s.website_url = JUMBO_DEALS_URL
      end
      if store.website_url != JUMBO_DEALS_URL
        store.update!(website_url: JUMBO_DEALS_URL)
      end
      puts "Store saved: #{store.inspect}"
      store
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Store: #{e.message}"
      nil
    end

    def save_product(deal_data)
      product = Product.find_or_create_by!(
        name: deal_data[:name],
        image_url: deal_data[:image_url],
        source: 'scraped'
      )
      puts "Saved or found product: #{product.inspect} for name: #{deal_data[:name]}"
      product
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Product: #{e.message}"
      nil
    end

    def save_deal(deal_data, store, product, parsed_expiry_date, index, category_name)
      standardized_category = CATEGORY_MAPPING[category_name] || category_name
      case category_name
      when "Vleeswaren, kaas en tapas"
        name = deal_data[:name].downcase
        standardized_category = "Cheese" if name.include?("kaas")
        standardized_category = "Meat & Fish" if name.match?(/vleeswaren|ham|spek|salami|worst/)
        standardized_category ||= "Deli"
      when "Drogisterij en baby"
        name = deal_data[:name].downcase
        standardized_category = "Baby Products" if name.match?(/luier|babyvoeding|speen|fles/)
        standardized_category ||= "Drugstore"
      when "Huishouden en dieren"
        name = deal_data[:name].downcase
        standardized_category = "Pet Products" if name.match?(/hondenvoer|kattenvoer|kattenbak|dieren/)
        standardized_category ||= "Household"
      end

      deal_attributes = {
        product_id: product.id,
        store_id: store.id,
        price: deal_data[:regular_price],
        discounted_price: deal_data[:discounted_price],
        expiry_date: parsed_expiry_date,
        deal_type: deal_data[:deal_type],
        deal_url: deal_data[:deal_url],
        category: standardized_category
      }
      puts "Deal attributes: #{deal_attributes.inspect}"

      existing_deal = Deal.find_by(
        product_id: product.id,
        store_id: store.id,
        discounted_price: deal_data[:discounted_price],
        expiry_date: parsed_expiry_date,
        deal_type: deal_data[:deal_type]
      )

      return if existing_deal

      deal_record = Deal.create!(deal_attributes)
      puts "Successfully saved Deal ##{index + 1} (ID: #{deal_record.id})"
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Deal ##{index + 1}: #{e.message}"
      nil
    end

    def log_deal(deal_data, index, expiry_date, category_name)
      standardized_category = CATEGORY_MAPPING[category_name] || category_name
      case category_name
      when "Vleeswaren, kaas en tapas"
        name = deal_data[:name].downcase
        standardized_category = "Cheese" if name.include?("kaas")
        standardized_category = "Meat & Fish" if name.match?(/vleeswaren|ham|spek|salami|worst/)
        standardized_category ||= "Deli"
      when "Drogisterij en baby"
        name = deal_data[:name].downcase
        standardized_category = "Baby Products" if name.match?(/luier|babyvoeding|speen|fles/)
        standardized_category ||= "Drugstore"
      when "Huishouden en dieren"
        name = deal_data[:name].downcase
        standardized_category = "Pet Products" if name.match?(/hondenvoer|kattenvoer|kattenbak|dieren/)
        standardized_category ||= "Household"
      end

      puts "\nDeal ##{index + 1}:"
      puts "  Name: #{deal_data[:name]}"
      puts "  Description: #{deal_data[:description]}"
      puts "  Regular Price: #{deal_data[:regular_price] ? '€' + deal_data[:regular_price].to_s : 'N/A'}"
      puts "  Discounted Price: #{deal_data[:discounted_price] ? '€' + deal_data[:discounted_price].to_s : 'N/A'}"
      puts "  Deal Type: #{deal_data[:deal_type]}"
      puts "  Image URL: #{deal_data[:image_url]}"
      puts "  Deal URL: #{deal_data[:deal_url]}" if deal_data[:deal_url]
      puts "  Expiry Date: #{parse_date(nil, expiry_date) || 'Using default'}"
      puts "  Original Category: #{category_name}"
      puts "  Standardized Category: #{standardized_category}"
    end

    def parse_date(deal, date_str)
      return nil unless date_str

      dutch_to_english = {
        'jan' => 'Jan', 'feb' => 'Feb', 'mrt' => 'Mar', 'apr' => 'Apr',
        'mei' => 'May', 'jun' => 'Jun', 'jul' => 'Jul', 'aug' => 'Aug',
        'sep' => 'Sep', 'okt' => 'Oct', 'nov' => 'Nov', 'dec' => 'Dec'
      }

      # Try HTML attribute first
      if deal && (expiration_date = deal['expiration-date'])
        begin
          return Date.parse(expiration_date)
        rescue ArgumentError
          # Fallback to string parsing
        end
      end

      # Match various date formats
      if match = date_str.match(/di (\d+ \w+)/) # e.g., "di 18 mrt"
        day, month = match[1].split
        english_date = "#{day} #{dutch_to_english[month.downcase]} #{Time.now.year}"
        return Date.strptime(english_date, '%d %b %Y')
      elsif match = date_str.match(/wo \d+ t\/m di (\d+ \w+)/) # e.g., "wo 12 t/m di 18 mrt"
        day, month = match[1].split
        english_date = "#{day} #{dutch_to_english[month.downcase]} #{Time.now.year}"
        return Date.strptime(english_date, '%d %b %Y')
      elsif match = date_str.match(/(\d+ \w+) t\/m (\d+ \w+)/) # e.g., "26 feb t/m 25 mrt"
        end_day, end_month = match[2].split
        english_date = "#{end_day} #{dutch_to_english[end_month.downcase]} #{Time.now.year}"
        return Date.strptime(english_date, '%d %b %Y')
      end

      nil # Explicit return if no match
    rescue ArgumentError => e
      puts "Date parsing error for '#{date_str}': #{e.message}"
      nil
    end
  end

  if __FILE__ == $0
    scraper = JumboScraper.new
    scraper.scrape
  end
end
