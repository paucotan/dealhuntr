# Load the Rails environment
require File.expand_path('../../../config/environment', __FILE__)

require 'selenium-webdriver'
require 'nokogiri'
require 'active_record'
require_relative '../../app/models/store'
require_relative '../../app/models/product'
require_relative '../../app/models/deal'

class AlbertHeijnScraper
  AH_BONUS_URL = 'https://www.ah.nl/bonus'.freeze
  TARGET_IMAGE_SELECTOR = 'picture.promotion-card-image_root__Zvkg9 img' # Updated selector

  CATEGORY_MAPPING = {
    # AH Categories (unchanged)
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

    # Jumbo Categories (unchanged)
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
    # Extract category from parent section's <h3> tag
    section = deal.ancestors('section[id]').first
    category = section&.at_css('h3.typography_heading-2__-bV1n')&.text&.strip || 'Uncategorized'

    # Extract fields
    name = deal.css('[data-testhook="card-title"]').text.strip
    description = deal.css('[data-testhook="card-description"]')&.text&.strip || 'No description'
    price_element = deal.at_css('[data-testhook="price"]')
    regular_price = price_element&.[]('data-testpricewas')&.gsub(',', '.')&.to_f
    discounted_price = price_element&.[]('data-testpricenow')&.gsub(',', '.')&.to_f
    deal_type = deal.css('[data-testhook="promotion-shields"]').text.strip.gsub(/(\d)([a-zA-Z])/, '\1 \2').gsub(/voor(\d+)/, 'voor \1').gsub(/\s+/, ' ').strip

    # Extract deal URL
    deal_url = deal['href']
    deal_url = "https://www.ah.nl#{deal_url}" if deal_url && !deal_url.start_with?('http')

    # Extract image URL
    image_url = extract_image_url(deal, index)

    regular_price_display = regular_price.nil? ? 'N/A' : regular_price

    deal_data = {
      name: name,
      description: description,
      regular_price: regular_price,
      regular_price_display: regular_price_display,
      discounted_price: discounted_price,
      deal_type: deal_type,
      image_url: image_url,
      deal_url: deal_url
    }

    store = save_store
    return unless store

    product = save_product(deal_data)
    return unless product

    save_deal(deal_data, store, product, parsed_expiry_date, index, category)

    log_deal(deal_data, index, expiry_date, category)
  end

  def extract_image_url(deal, index)
    image_element = deal.at_css(TARGET_IMAGE_SELECTOR)
    puts "Debug: No image element found for Deal ##{index + 1}, HTML snippet: #{deal.to_s[0..200]}..." unless image_element
    return nil unless image_element

    temp_image_url = image_element['data-src'] || image_element['src']
    puts "Debug: Initial temp_image_url for Deal ##{index + 1}: #{temp_image_url}"

    return temp_image_url unless temp_image_url.match?(/data:image\/gif;base64/)

    puts "Debug: Detected base64 image, scrolling into view for Deal ##{index + 1}"
    @driver.execute_script("arguments[0].scrollIntoView(true);", @driver.find_element(:css, "a.promotion-card_root__tQA3z:nth-child(#{index + 1}) #{TARGET_IMAGE_SELECTOR}"))
    begin
      wait = Selenium::WebDriver::Wait.new(timeout: 10) # Increased timeout
      image_url = wait.until do
        src = @driver.find_element(:css, "a.promotion-card_root__tQA3z:nth-child(#{index + 1}) #{TARGET_IMAGE_SELECTOR}")['src']
        puts "Debug: Waiting for src: #{src}"
        src unless src.match?(/data:image\/gif;base64/)
      end
    rescue Selenium::WebDriver::Error::TimeoutError
      puts "Debug: Timeout waiting for image to load for Deal ##{index + 1}, using nil"
      nil
    end
  end

  def save_store
    store = Store.find_or_create_by!(name: 'Albert Heijn') do |s|
      s.website_url = AH_BONUS_URL
    end
    if store.website_url != AH_BONUS_URL
      store.update!(website_url: AH_BONUS_URL)
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
    product.update!(description: deal_data[:description]) if product.description.nil? || product.description.empty?
    puts "Product saved: #{product.inspect}"
    product
  rescue ActiveRecord::RecordInvalid => e
    puts "Failed to save Product: #{e.message}"
    nil
  end

  def save_deal(deal_data, store, product, parsed_expiry_date, index, category_name)
    # Normalize the category
    standardized_category = CATEGORY_MAPPING[category_name] || category_name

    deal_attributes = {
      product_id: product.id,
      store_id: store.id,
      price: deal_data[:regular_price_display] == 'N/A' ? nil : deal_data[:regular_price],
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
      english_month = dutch_to_english[month.downcase]
      return nil unless english_month

      # Assume the year is the current year unless the date is in the past, then use next year
      current_year = Time.now.year
      parsed_date = Date.strptime("#{day} #{english_month} #{current_year}", '%d %b %Y')
      if parsed_date < Date.today
        parsed_date = Date.strptime("#{day} #{english_month} #{current_year + 1}", '%d %b %Y')
      end
      parsed_date
    rescue ArgumentError
      puts "Failed to parse date: #{date_str}"
      nil
    end
  end
end

# Run it
if __FILE__ == $0
  scraper = AlbertHeijnScraper.new
  scraper.scrape
end
