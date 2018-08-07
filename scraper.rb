#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  table = noko.xpath('//h2[span[@id="Members"]]/following-sibling::table[1]') or raise "No table"
  table.css('tr').drop(1).each do |tr|
    td = tr.css('td')
    data = {
      name: td[0].text.tidy,
      wikiname: td[0].xpath('a[not(@class="new")]/@title').text,
      constituency: td[1].text.tidy,
      party: 'unknown',
      term: 9,
    }
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite([:name, :constituency, :term], data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('https://en.wikipedia.org/wiki/9th_Parliament_of_Kiribati')
