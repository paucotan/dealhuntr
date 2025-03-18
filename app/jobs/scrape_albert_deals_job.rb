# app/jobs/scrape_albert_deals_job.rb
require_relative '../../lib/scrapers/albert_heijn_scraper' # Adjust path if needed

class ScrapeAlbertDealsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting AH scrape job at #{Time.now}"
    puts "Starting AH scrape job..." # For console visibility
    scraper = AlbertHeijnScraper.new
    scraper.scrape
    Rails.logger.info "AH scrape job completed at #{Time.now}"
    puts "AH scrape job completed!"
  rescue StandardError => e
    Rails.logger.error "AH scrape job failed: #{e.message}\n#{e.backtrace.join("\n")}"
    puts "Error: #{e.message}"
    raise # Re-raise to mark job as failed in Solid Queue
  end
end
