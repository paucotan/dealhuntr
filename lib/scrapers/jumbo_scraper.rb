require File.expand_path('config/environment', Dir.pwd)

require 'selenium-webdriver'
require 'nokogiri'
require 'active_record'
require_relative '../../app/models/store'
require_relative '../../app/models/product'
require_relative '../../app/models/deal'

class JumboScraper
  JUMBO_DEALS_URL = 'https://www.jumbo.com/aanbiedingen/nu'.freeze
  DEAL_CARD_SELECTOR = 'li.jum-card.card-promotion'.freeze
  EXPIRY_DATE_SELECTOR = 'p.description[data-v-1a478f07]'.freeze
  IMAGE_SELECTOR = 'img.image'.freeze
  TITLE_SELECTOR = 'h3.title'.freeze
  DEAL_TYPE_SELECTOR = '.jum-tag .lower'.freeze
  SUBTITLE_SELECTOR = 'p.subtitle'.freeze

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @driver.manage.timeouts.implicit_wait = 10
  end

  def scrape
    begin
      puts "Opening #{JUMBO_DEALS_URL}..."
      @driver.get(JUMBO_DEALS_URL)
      sleep 5
      puts "Page loaded. Grabbing HTML..."

      html = @driver.page_source
      doc = Nokogiri::HTML(html)

      expiry_date = doc.at_css(EXPIRY_DATE_SELECTOR)&.text[/Tot en met (\w+ \d+ \w+)/, 1]&.gsub('dinsdag', '')&.strip
      puts "Expiry Date: #{expiry_date}"

      parsed_expiry_date = parse_date(expiry_date)
      puts "Parsed Expiry Date: #{parsed_expiry_date}"

      deals = doc.css(DEAL_CARD_SELECTOR)
      puts "Found #{deals.count} deal cards."

      deals.each_with_index do |deal, index|
        process_deal(deal, expiry_date, parsed_expiry_date, index)
      end

      puts "Scraping done!"
    rescue Selenium::WebDriver::Error::WebDriverError => e
      puts "Website is down or inaccessible: #{e.message}. Skipping scrape."
    rescue StandardError => e
      puts "An error occurred during scraping: #{e.message}. Consider checking the website status."
    ensure
      @driver.quit
    end
  end

  private

  def process_deal(deal, expiry_date, parsed_expiry_date, index)
    deal_data = extract_deal_data(deal, index)
    return if deal_data.nil?

    store = save_store
    return unless store

    product = save_product(deal_data)
    return unless product

    save_deal(deal_data, store, product, parsed_expiry_date, index)

    log_deal(deal_data, index, expiry_date)
  end

  def extract_deal_data(deal, index)
    name = deal.at_css(TITLE_SELECTOR)&.text&.strip || 'No name'
    subtitle = deal.at_css(SUBTITLE_SELECTOR)&.text&.strip || 'No subtitle'
    deal_type_element = deal.at_css('.jum-tag .lower')
    deal_type_text = deal_type_element&.text&.strip || 'No deal type'

    # Extract the deal URL from the title link
    deal_url = deal.at_css('h3.title a.title-link')&.[]('href')
    deal_url = "https://www.jumbo.com#{deal_url}" if deal_url && !deal_url.start_with?('http')

    # Initialize prices
    regular_price = nil # Jumbo doesn't provide regular price
    discounted_price = 0.0

    # Parse deal type and price if present
    if deal_type_text.present? && deal_type_text.match?(/(\d+)\s*(?:voor|for)\s*€?([\d,.]+)/i)
      match = deal_type_text.match(/(\d+)\s*(?:voor|for)\s*€?([\d,.]+)/i)
      quantity = match[1].to_i
      total_price = match[2].gsub(',', '.').to_f
      discounted_price = total_price # Total price for the quantity
      # Estimate regular price with 25% discount (33.3% markup)
      regular_price = (total_price / 0.75).round(2) if total_price > 0
    elsif deal_type_text.present? # No price, e.g., "2+1 gratis" or "25% korting"
      discounted_price = -1.0 # Flag for manual review or no price
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
    image_element = deal.at_css(IMAGE_SELECTOR)
    return 'No image' unless image_element

    temp_image_url = image_element['src']
    unless temp_image_url.match?(/data:image\/gif;base64/)
      return temp_image_url
    end

    begin
      @driver.execute_script("arguments[0].scrollIntoView(true);", @driver.find_element(:css, "#{DEAL_CARD_SELECTOR}:nth-child(#{index + 1}) #{IMAGE_SELECTOR}"))
      wait = Selenium::WebDriver::Wait.new(timeout: 5)
      wait.until do
        src = @driver.find_element(:css, "#{DEAL_CARD_SELECTOR}:nth-child(#{index + 1}) #{IMAGE_SELECTOR}")['src']
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
    product = Product.find_or_create_by!(name: deal_data[:name], image_url: deal_data[:image_url], source: 'scraped')
    puts "Product saved: #{product.inspect}"
    product
  rescue ActiveRecord::RecordInvalid => e
    puts "Failed to save Product: #{e.message}"
    nil
  end

  def save_deal(deal_data, store, product, parsed_expiry_date, index)
    deal_attributes = {
      product_id: product.id,
      store_id: store.id,
      price: deal_data[:regular_price_display] == 'N/A' ? nil : deal_data[:regular_price],
      discounted_price: deal_data[:discounted_price],
      expiry_date: parsed_expiry_date,
      deal_type: deal_data[:deal_type],
      deal_url: deal_data[:deal_url]
    }
    puts "Deal attributes: #{deal_attributes.inspect}"

    existing_deal = Deal.find_by(
      product_id: product.id,
      store_id: store.id,
      discounted_price: deal_data[:discounted_price],
      expiry_date: parsed_expiry_date,
      deal_type: deal_data[:deal_type]
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

  def log_deal(deal_data, index, expiry_date)
    puts "\nDeal ##{index + 1}:"
    puts "  Name: #{deal_data[:name]}"
    puts "  Description: #{deal_data[:description]}"
    puts "  Regular Price: #{deal_data[:regular_price_display].is_a?(Numeric) ? '€' + deal_data[:regular_price_display].to_s : deal_data[:regular_price_display]}"
    puts "  Discounted Price: €#{deal_data[:discounted_price]}"
    puts "  Deal Type: #{deal_data[:deal_type]}"
    puts "  Image URL: #{deal_data[:image_url]}"
    puts "  Deal URL: #{deal_data[:deal_url]}" if deal_data[:deal_url]
    puts "  Expiry Date: #{expiry_date}"
  end

  def parse_date(date_str)
    return nil unless date_str

    dutch_to_english = {
      'jan' => 'Jan', 'feb' => 'Feb', 'mrt' => 'Mar', 'apr' => 'Apr',
      'mei' => 'May', 'jun' => 'Jun', 'jul' => 'Jul', 'aug' => 'Aug',
      'sep' => 'Sep', 'okt' => 'Oct', 'nov' => 'Nov', 'dec' => 'Dec'
    }

    begin
      day, month = date_str.split.last(2) # Extract last two parts (e.g., "18 mrt")
      english_date = "#{day} #{dutch_to_english[month.downcase]}"
      Date.strptime(english_date, '%d %b')
    rescue ArgumentError
      nil
    end
  end
end

if __FILE__ == $0
  scraper = JumboScraper.new
  scraper.scrape
end
