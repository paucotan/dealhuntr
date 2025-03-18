# app/jobs/scrape_jumbo_deals_job.rb
require_relative '../../lib/scrapers/jumbo_scraper' # Adjust path if needed

class ScrapeJumboDealsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting Jumbo scrape job at #{Time.now}"
    puts "Starting Jumbo scrape job..." # For console visibility
    scraper = JumboScraper.new
    scraper.scrape
    Rails.logger.info "Jumbo scrape job completed at #{Time.now}"
    puts "Jumbo scrape job completed!"
  rescue StandardError => e
    Rails.logger.error "Jumbo scrape job failed: #{e.message}\n#{e.backtrace.join("\n")}"
    puts "Error: #{e.message}"
    raise # Re-raise to mark job as failed in Solid Queue
  end
end
