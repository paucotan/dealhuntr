# lib/scrapers/albert_heijn_scraper.rb
require 'selenium-webdriver'
require 'nokogiri'
require 'active_record'  # Add this
require_relative '../../app/models/store'  # Add these to load models
require_relative '../../app/models/product'
require_relative '../../app/models/deal'

class AlbertHeijnScraper
  AH_BONUS_URL = 'https://www.ah.nl/bonus'.freeze

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @driver.manage.timeouts.implicit_wait = 10
  end

  def scrape
    puts "Opening #{AH_BONUS_URL}..."
    @driver.get(AH_BONUS_URL)
    sleep 5 # Extra wait for JS to load
    puts "Page loaded. Grabbing HTML..."

    html = @driver.page_source
    doc = Nokogiri::HTML(html)

    # Get expiry date from the nested header structure
    expiry_date = doc.at_css('span.period-toggle-button_label__rRyWQ')&.text[/t\/m (\d+ \w+)/, 1]
    puts "Expiry Date: #{expiry_date}"

    # Parse the expiry date safely
    parsed_expiry_date = parse_date(expiry_date)
    puts "Parsed Expiry Date: #{parsed_expiry_date}"

    # Find deal cards
    deals = doc.css('a.promotion-card_root__tQA3z')
    puts "Found #{deals.count} deal cards."

    # Limit to first 5 deals for testing
    deals.first(5).each_with_index do |deal, index|
      process_deal(deal, expiry_date, parsed_expiry_date, index)
    end

    # Uncomment code below to scrape all deals:
    # deals.each_with_index do |deal, index|
     # process_deal(deal, expiry_date, parsed_expiry_date, index)
    # end

    puts "Scraping done!"
    @driver.quit
  end

  private

  def process_deal(deal, expiry_date, parsed_expiry_date, index)
    # Extract fields
    name = deal.css('[data-testhook="card-title"]').text.strip
    description = deal.css('[data-testhook="card-description"]')&.text&.strip || 'No description'
    price_element = deal.at_css('[data-testhook="price"]')
    regular_price = price_element&.[]('data-testpricewas')&.gsub(',', '.')&.to_f || 0.0
    discounted_price = price_element&.[]('data-testpricenow')&.gsub(',', '.')&.to_f || 0.0
    deal_type = deal.css('[data-testhook="promotion-shields"]').text.strip.gsub(/(\d)([a-zA-Z])/, '\1 \2').gsub(/voor(\d)/, 'voor \1')
    image_url = deal.css('img').first&.[]('src') || 'No image'

    # Only show regular price if it exists
    regular_price_display = regular_price.zero? && price_element&.[]('data-testpricewas').nil? ? 'N/A' : regular_price

    # Save to database with explicit error handling
    begin
      # Find or create store by name only
      store = Store.find_or_create_by!(name: 'Albert Heijn') do |s|
        s.website_url = AH_BONUS_URL
      end
      if store.website_url != AH_BONUS_URL
        store.update!(website_url: AH_BONUS_URL)
      end
      puts "Store saved: #{store.inspect}"
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Store: #{e.message}"
      return
    end

    begin
      product = Product.find_or_create_by!(name: name, image_url: image_url, source: 'scraped')
      puts "Product saved: #{product.inspect}"
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Product: #{e.message}"
      return
    end

    begin
      deal_attributes = {
        product_id: product.id,
        store_id: store.id,
        price: regular_price_display == 'N/A' ? nil : regular_price,
        discounted_price: discounted_price,
        expiry_date: parsed_expiry_date
      }
      puts "Deal attributes: #{deal_attributes.inspect}"

      # Check for existing deal to avoid duplicates
      existing_deal = Deal.find_by(
        product_id: product.id,
        store_id: store.id,
        discounted_price: discounted_price,
        expiry_date: parsed_expiry_date
      )

      if existing_deal
        puts "Deal ##{index + 1} already exists (ID: #{existing_deal.id}), skipping..."
        return
      end

      deal_record = Deal.create!(deal_attributes)
      puts "Deal record: #{deal_record.inspect}"
      if deal_record.persisted?
        puts "Successfully saved Deal ##{index + 1} (ID: #{deal_record.id})"
      else
        puts "Failed to persist Deal ##{index + 1}: #{deal_record.errors.full_messages.join(', ')}"
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save Deal ##{index + 1}: #{e.message}"
    rescue StandardError => e
      puts "Error saving Deal ##{index + 1}: #{e.message}"
    end

    # Print the deal
    puts "\nDeal ##{index + 1}:"
    puts "  Name: #{name}"
    puts "  Description: #{description}"
    puts "  Regular Price: #{regular_price_display.is_a?(Numeric) ? "€#{regular_price_display}" : regular_price_display}"
    puts "  Discounted Price: €#{discounted_price}"
    puts "  Deal Type: #{deal_type}"
    puts "  Image URL: #{image_url}"
    puts "  Expiry Date: #{expiry_date}"
  end

  def parse_date(date_str)
    return nil unless date_str

    # Map Dutch months to English
    dutch_to_english = {
      'jan' => 'Jan', 'feb' => 'Feb', 'mrt' => 'Mar', 'apr' => 'Apr',
      'mei' => 'May', 'jun' => 'Jun', 'jul' => 'Jul', 'aug' => 'Aug',
      'sep' => 'Sep', 'okt' => 'Oct', 'nov' => 'Nov', 'dec' => 'Dec'
    }

    begin
      day, month = date_str.split
      english_date = "#{day} #{dutch_to_english[month.downcase]}"
      Date.strptime(english_date, '%d %b')
    rescue ArgumentError
      nil
    end
  end
end

# Run it
if __FILE__ == $0
  scraper = AlbertHeijnScraper.new
  scraper.scrape
end
