require File.expand_path('config/environment', Dir.pwd)

require 'selenium-webdriver'
require 'nokogiri'
require 'active_record'
require_relative '../../app/models/store'
require_relative '../../app/models/product'
require_relative '../../app/models/deal'

class JumboScraper
  JUMBO_DEALS_URL = 'https://www.jumbo.com/aanbiedingen/nu'.freeze
  CATEGORY_SELECTOR = 'section.category-section'.freeze
  CATEGORY_NAME_SELECTOR = 'h4.jum-heading.h4.category-heading strong'.freeze
  DEAL_CARD_GRID_SELECTOR = 'div.jum-card-grid'.freeze
  DEAL_CARD_SELECTOR = 'article.jum-card.card-promotion'.freeze
  EXPIRY_DATE_SELECTOR = 'p.subtitle'.freeze
  TARGET_IMAGE_SELECTOR = 'div.card-image img'.freeze
  TITLE_SELECTOR = 'h3.jum-heading.bold.h6.title'.freeze
  DEAL_TYPE_SELECTOR = '.jum-tag .lower'.freeze
  SUBTITLE_SELECTOR = 'p.subtitle'.freeze

  CATEGORY_MAPPING = {
    # AH Categories
    "Groente, aardappelen" => "Fruits & Vegetables",
    "Fruit, verse sappen" => "Fruits & Vegetables",
    "Maaltijden, salades" => "Ready Meals",
    "Vlees" => "Meat & Fish",
    "Vleeswaren" => "Meat & Fish",
    "Kaas" => "Cheese",
    "Zuivel, eieren" => "Dairy & Eggs",
    "Bakkerij" => "Bakery",
    "Borrel, chips, snacks" => "Snacks & Sweets",
    "Pasta, rijst, wereldkeuken" => "Pasta, Rice & International",
    "Soepen, sauzen, kruiden, olie" => "Canned Goods & Condiments",
    "Snoep, chocolade, koek" => "Snacks & Sweets",
    "Ontbijtgranen, beleg" => "Breakfast & Spreads",
    "Diepvries" => "Frozen Foods",
    "Koffie, thee" => "Coffee & Tea",
    "Frisdrank, sappen, water" => "Beverages",
    "Bier, wijn, aperitieven" => "Alcohol",
    "Drogisterij" => "Drugstore",
    "Huishouden" => "Household",
    "Baby en kind" => "Baby Products",
    "Koken, tafelen, vrije tijd" => "Non-Food",
    "Pasen" => "Seasonal",
    "Alleen online" => "Online Only",
    "Online aanbiedingen" => "Online Only",
    "Gall & Gall acties" => "Alcohol",
    "Gall & Gall Premium" => "Alcohol",
    "Etos acties" => "Drugstore",

    # Jumbo Categories
    "Aardappelen, groente en fruit" => "Fruits & Vegetables",
    "Verse maaltijden en gemak" => "Ready Meals",
    "Vlees, vis en vega" => "Meat & Fish",
    "Brood en gebak" => "Bakery",
    "Vleeswaren, kaas en tapas" => "Deli", # Default; will refine with product name logic
    "Zuivel, eieren, boter" => "Dairy & Eggs",
    "Conserven, soepen, sauzen, oliën" => "Canned Goods & Condiments",
    "Wereldkeukens, kruiden, pasta en rijst" => "Pasta, Rice & International",
    "Ontbijt, broodbeleg en bakproducten" => "Breakfast & Spreads",
    "Koek, snoep, chocolade en chips" => "Snacks & Sweets",
    "Koffie en thee" => "Coffee & Tea",
    "Frisdrank en sappen" => "Beverages",
    "Bier en wijn" => "Alcohol",
    # Removed duplicate "Diepvries" => "Frozen Foods"
    "Drogisterij en baby" => "Drugstore", # Default; will refine with product name logic
    "Huishouden en dieren" => "Household", # Default; will refine with product name logic
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
      sleep 5
      puts "Page loaded. Grabbing HTML..."

      html = @driver.page_source
      doc = Nokogiri::HTML(html)

      categories = doc.css(CATEGORY_SELECTOR)
      puts "Found #{categories.count} categories."

      categories.each_with_index do |category, category_index|
        category_name = category.at_css(CATEGORY_NAME_SELECTOR)&.text&.strip || "Unknown Category ##{category_index + 1}"
        puts "\nProcessing Category ##{category_index + 1}: #{category_name}"

        deal_grid = category.at_css(DEAL_CARD_GRID_SELECTOR)
        unless deal_grid
          puts "No deal grid found for category '#{category_name}'. Skipping..."
          next
        end

        deals = deal_grid.css(DEAL_CARD_SELECTOR)
        puts "Found #{deals.count} deals in category '#{category_name}'."

        deals.each_with_index do |deal, deal_index|
          expiry_date = deal.at_css(EXPIRY_DATE_SELECTOR)&.text&.strip&.match(/wo \d+ t\/m di (\d+ \w+)/)&.[](1)
          process_deal(deal, expiry_date, deal_index, category_name)
        end
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

  def process_deal(deal, expiry_date, index, category_name)
    deal_data = extract_deal_data(deal, index)
    return if deal_data.nil?

    store = save_store
    return unless store

    product = save_product(deal_data)
    return unless product

    parsed_expiry_date = parse_date(deal, expiry_date)
    save_deal(deal_data, store, product, parsed_expiry_date, index, category_name)

    log_deal(deal_data, index, expiry_date, category_name)
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
    discounted_price = 0.0

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
        percentage = deal_type_text.match(/([\d.]+)% korting/i)[1].to_f
        discounted_price = nil
      else
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
    # Normalize the category
    standardized_category = CATEGORY_MAPPING[category_name] || category_name

    # Handle ambiguous categories with product name logic
    case category_name
    when "Vleeswaren, kaas en tapas"
      name = deal_data[:name].downcase
      if name.include?("kaas")
        standardized_category = "Cheese"
      elsif name.match?(/vleeswaren|ham|spek|salami|worst/)
        standardized_category = "Meat & Fish"
      else
        standardized_category = "Deli" # Default for tapas or ambiguous items
      end
    when "Drogisterij en baby"
      name = deal_data[:name].downcase
      if name.match?(/luier|babyvoeding|speen|fles/)
        standardized_category = "Baby Products"
      else
        standardized_category = "Drugstore"
      end
    when "Huishouden en dieren"
      name = deal_data[:name].downcase
      if name.match?(/hondenvoer|kattenvoer|kattenbak|dieren/)
        standardized_category = "Pet Products"
      else
        standardized_category = "Household"
      end
    end

    deal_attributes = {
      product_id: product.id,
      store_id: store.id,
      price: deal_data[:regular_price_display] == 'N/A' ? nil : deal_data[:regular_price],
      discounted_price: deal_data[:discounted_price],
      expiry_date: parsed_expiry_date,
      deal_type: deal_data[:deal_type],
      deal_url: deal_data[:deal_url],
      category: standardized_category # Use the standardized category
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

  def log_deal(deal_data, index, expiry_date, category_name)
    standardized_category = CATEGORY_MAPPING[category_name] || category_name

    # Apply the same product name logic as in save_deal to ensure consistency
    case category_name
    when "Vleeswaren, kaas en tapas"
      name = deal_data[:name].downcase
      if name.include?("kaas")
        standardized_category = "Cheese"
      elsif name.match?(/vleeswaren|ham|spek|salami|worst/)
        standardized_category = "Meat & Fish"
      else
        standardized_category = "Deli"
      end
    when "Drogisterij en baby"
      name = deal_data[:name].downcase
      if name.match?(/luier|babyvoeding|speen|fles/)
        standardized_category = "Baby Products"
      else
        standardized_category = "Drugstore"
      end
    when "Huishouden en dieren"
      name = deal_data[:name].downcase
      if name.match?(/hondenvoer|kattenvoer|kattenbak|dieren/)
        standardized_category = "Pet Products"
      else
        standardized_category = "Household"
      end
    end

    puts "\nDeal ##{index + 1}:"
    puts "  Name: #{deal_data[:name]}"
    puts "  Description: #{deal_data[:description]}"
    puts "  Regular Price: #{deal_data[:regular_price_display].is_a?(Numeric) ? '€' + deal_data[:regular_price_display].to_s : deal_data[:regular_price_display]}"
    puts "  Discounted Price: €#{deal_data[:discounted_price]}"
    puts "  Deal Type: #{deal_data[:deal_type]}"
    puts "  Image URL: #{deal_data[:image_url]}"
    puts "  Deal URL: #{deal_data[:deal_url]}" if deal_data[:deal_url]
    puts "  Expiry Date: #{expiry_date}"
    puts "  Original Category: #{category_name}"
    puts "  Standardized Category: #{standardized_category}"
  end

  def parse_date(deal, date_str)
    return nil unless date_str

    expiration_date = deal['expiration-date']
    if expiration_date
      begin
        return Date.parse(expiration_date)
      rescue ArgumentError
        # Fallback to parsing the date string
      end
    end

    dutch_to_english = {
      'jan' => 'Jan', 'feb' => 'Feb', 'mrt' => 'Mar', 'apr' => 'Apr',
      'mei' => 'May', 'jun' => 'Jun', 'jul' => 'Jul', 'aug' => 'Aug',
      'sep' => 'Sep', 'okt' => 'Oct', 'nov' => 'Nov', 'dec' => 'Dec'
    }

    begin
      day, month = date_str.split.last(2)
      english_date = "#{day} #{dutch_to_english[month.downcase]} #{Time.now.year}"
      Date.strptime(english_date, '%d %b %Y')
    rescue ArgumentError
      nil
    end
  end
end

if __FILE__ == $0
  scraper = JumboScraper.new
  scraper.scrape
end
