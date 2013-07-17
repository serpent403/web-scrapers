require 'nokogiri'
require 'open-uri'

SITE = 'http://www.tradus.com'
DOMAIN = 'tradus.com'

nav_links     = []
item_links    = []
results_links = []
title         = ''
price         = ''

# parsing home page
doc = Nokogiri::HTML(open(SITE))
nav_anchors = doc.css('div.tradus-hp-best-selling-viewall a')
nav_links = nav_anchors.collect { |e| e.attributes['href'].value }

p "Navigation Links"
p nav_links.count
p nav_links

nav_links.each do |nav_link|
  p "Parsing #{nav_link}"
  doc = Nokogiri::HTML(open(nav_link))
  if nav_link.include?('clothing-apparels') # this page is different from others
    results_anchors = doc.css('div.arrivalsDiv a')
  else
    results_anchors = doc.css('a.Nonfiltered1')
  end
  results_links += results_anchors.collect { |e| e.attributes['href'].value } unless results_anchors.empty?
  p "Results Links : #{results_links.count}"
end

results_links.uniq!
p "Results Links"
p results_links.count
p results_links

results_links.each do |results_link|
  results_link = results_link.include?(DOMAIN) ? results_link : "#{SITE}#{results_link}"

  page = 0
  item_anchors = []

  begin
    p "Parsing #{results_link}?Page=#{page}"
    doc = Nokogiri::HTML(open("#{results_link}?Page=#{page}"))
    item_anchors = doc.css('div.tradus-horizontal-strip-body-content a')
    item_anchors = doc.css('div.product_image a') if item_anchors.empty?
    item_links += item_anchors.collect { |e| e.attributes['href'].value.include?(DOMAIN) ? e.attributes['href'].value : "#{SITE}#{e.attributes['href'].value}" } unless item_anchors.empty?
    page += 1
    puts "Item Links : #{item_links.count}"
  end while !item_anchors.empty? && page < 500
end

item_links.uniq!
p "Item Links"
p item_links.count
p item_links

item_links.each do |item_link|
  p "Parsing #{item_link}"
  doc = Nokogiri::HTML(open(item_link))
  title_h1 = doc.css('div.left-content-product-heading h1')
  title = title_h1.first.children.first.to_s

  price_spans = doc.css('span#whole-sale-price span')
  price_spans.each { |e| price = e.children.last.to_s if !e.attributes.empty? && !e.attributes['itemprop'].nil? && e.attributes['itemprop'].value == 'highPrice' }
  p "TITLE : #{title}"
  p "PRICE : #{price}"
end


