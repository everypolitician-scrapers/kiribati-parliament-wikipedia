#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  table = noko.xpath('//h2[span[@id="Members"]]/following-sibling::table[1]') or raise "No table"
  table.css('tr').drop(1).each do |tr|
    td = tr.css('td')
    data = { 
      name: td[0].text,
      wikiname: td[0].xpath('a[not(@class="new")]/@title').text,
      constituency: td[1].text,
      party: 'unknown',
      term: 10,
    }
    ScraperWiki.save_sqlite([:name, :constituency, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/9th_Parliament_of_Kiribati')
