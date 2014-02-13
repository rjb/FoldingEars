#!/usr/bin/ruby
print "Content-type: text/html\r\n\r\n"
print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" 
	\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">
	<head>

		<meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\" />
		<meta http-equiv=\"Content-Language\" content=\"en-us\" />
		
		<title>FoldingEars</title>
			<link href=\"http://timeinavacuum.com/foldingears/screen.css\" rel=\"stylesheet\" type=\"text/css\">

		<meta name=\"ROBOTS\" content=\"NONE\" />
		<meta http-equiv=\"imagetoolbar\" content=\"no\" />
		<meta name=\"MSSmartTagsPreventParsing\" content=\"true\" />
		<meta name=\"Copyright\" content=\"(c) 2005 Copyright content:  Copyright design: Folding Ears\" />        		
	</head>
	<body>
		<b>FoldingEars:</b> bestPrice?<br/>
"
# Author: Raffy Banks
# Date Created: Dec. 14, 2005
# Date Last Modified: Dec. 20, 2005

require 'cgi'
require 'rexml/document'
require 'open-uri'

def get_isbn(url, exp)
  "#{$&}" if url =~ exp
end

def get_book_pool_price(html, exp)
  "#{$&}" if html =~ exp
end
# Combine to One
def get_bn_price(html, exp)
  "#{$&}" if html =~ exp
end

def amazon_find(isbn)
  @url_amazon = "http://www.amazon.com/gp/product/#{isbn}"
  @url_m_amazon = "http://www.amazon.com/gp/product/offer-listing/#{isbn}"
  @url_m_used_amazon = "http://www.amazon.com/gp/product/offer-listing/#{isbn}/ref=olp_tab_used/102-0954355-4616102?%5Fencoding=UTF8&condition=used"

  nethttp = "http://webservices.amazon.com/onca/xml?"
    nethttp << "Service=AWSECommerceService&"
    nethttp << "AWSAccessKeyId=07XMN0CJNG7JP2CMYX82&"
    nethttp << "Operation=ItemLookup&"
    nethttp << "ItemId=#{isbn}&"
    nethttp << "ResponseGroup=OfferFull"

  xml = REXML::Document.new(open(nethttp))

  if !xml.elements["//Errors/Error/Code"] # If no errors. IE. if they carry the book
    @new_m_price = xml.elements["//LowestNewPrice/FormattedPrice"].text
    @used_m_price = xml.elements["//LowestUsedPrice/FormattedPrice"].text
    @new_price = xml.elements["//Price/FormattedPrice"].text

    @isbn = xml.elements["//ASIN"].text    
	 @image_url = "http://images.amazon.com/images/P/#{@isbn}.01.THUMBZZZ.jpg"
	 @book_title = "asd"
  else
	 @new_m_price = "na"
	 @used_m_price = "na"
	 @new_price = "na"
  end
end

def bn_find(isbn)
  @url_bn = "http://search.barnesandnoble.com/booksearch/isbnInquiry.asp?isbn=#{isbn}"

  @new_array = Array.new
  open("http://search.barnesandnoble.com/booksearch/isbnInquiry.asp?isbn=#{isbn}") do |f|
    0.upto(90) { |i| @new_array.concat([f.gets]) }
  end

  @bn_string = ""
  42.upto(51) { |i| @bn_string << @new_array[i] }

  @bn_price = get_bn_price(@bn_string, /priceRightBNPrice\"\>\$[1-9]{0,4}.[0-9]{0,4}/)
  if @bn_price != nil
    @bn_price.delete!('priceRightBNPrice"\>')
  else
	 @bn_price = "na"
  end

  @list_price = get_bn_price(@bn_string, /priceRightList\"\>\$[1-9]{0,4}.[0-9]{0,4}/)
  if @list_price != nil
    @list_price.delete!('priceRightList"\>')
  else
	 @list_price = @bn_price
  end

  @bn_info_array = @new_array[0].split('-')
  @title = @bn_info_array[1] 
  @author =  @bn_info_array[2]
  if @title != nil
    @title.delete!("")
  else
	 @title = "Sorry. Could not get title."
  end

  if @author != nil
    @author.delete!("")
  else
	 @author = "Sorry. Could not get author"
  end
end

def powells_find(isbn)
  @url_powells = "http://www.powells.com/biblio/#{isbn}"
end

def book_pool_find(isbn)
  @url_book_pool = "http://www.bookpool.com/sm/#{isbn}"

  @new_array = Array.new
  open("http://www.bookpool.com/sm/#{isbn}/") do |f|
    0.upto(46) { |i| @new_array.concat([f.gets]) }
    @book_pool_price = get_book_pool_price(@new_array[45], /\<b\>\$[1-9]{0,4}.[0-9]{0,4}\<\/b\>/)
    if @book_pool_price != nil
      @book_pool_price=@book_pool_price.delete!("</b>")
    else
      @book_pool_price = "na"
    end
  end
end

def online_edition_find(isbn)
  @isbn = isbn
  i=0
  @url_online_edition = "na"
  @online_edition_price = "na"
  @online_edition_type = "na"
	# needs to move - no reason to istanciate on each request
  @online_editions = ( @oe_1 = { "isbn"  => "0596004486",
							  		      "title" => "Version Control with Subversion",
							  		      "price" => "free",
							  		      "url"   => "http://svnbook.red-bean.com/",
										   "type"  => "html" },
                       
							  @oe_2 = { "isbn"  => "1590592395",
							   		   "title" => "Practical Common Lisp",
								 		   "price" => "free", 
								         "url"   => "http://www.gigamonkeys.com/book/", 
								         "type"  => "html" },

							  @oe_3 = { "isbn"  => "097669400X",
							   		   "title" => "Agile Web Development with Rails",
							    		   "price" => "$22.50", 
							            "url"   => "http://pragmaticprogrammer.com/titles/rails/index.html/", 
							            "type"  => "pdf" },
							  
							  @oe_3 = { "isbn"  => "1558605347",
							     		   "title" => "Philip and Alex's Guide to Web Publishing",
							      		"price" => "free", 
							            "url"   => "http://philip.greenspun.com/panda/", 
							            "type"  => "html" } )

  @online_editions.each { |book|
	 if @online_editions[i]["isbn"] == @isbn
	   @url_online_edition = @online_editions[i]["url"]
	   @online_edition_price = @online_editions[i]["price"]
	   @online_edition_type = @online_editions[i]["type"]
	   break
	 end
    i+=1
  }
end

cgi = CGI.new
url = cgi['url']
isbn = get_isbn(url, /[0-9Xx]{10}/)

if isbn
  isbn.upcase! # upcase for x to X when redirecting to amazon merchant area (needs capitalized X for some reason)
  book_hash = { "url"  => url, "isbn" => isbn }

  amazon_find(book_hash['isbn'])
  bn_find(book_hash['isbn'])
  book_pool_find(book_hash['isbn'])
  online_edition_find(book_hash['isbn'])
  powells_find(book_hash['isbn'])

print "
	<div id=\"content\">
<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_amazon}\" target=\"new_window\">Amazon:</a></td>
		<td align=\"right\">#{@new_price}<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_m_amazon}\" target=\"new_window\">Amazon <small>merch. (new)</small>:</a></td>
		<td align=\"right\">#{@new_m_price}<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_m_used_amazon}\" target=\"new_window\">Amazon <small>merch. (used)</small>:</a></td>
		<td align=\"right\">#{@used_m_price}<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_bn}\" target=\"new_window\">Barnes & Noble:</a></td>
		<td align=\"right\">#{@bn_price}<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_book_pool}\" target=\"new_window\">BookPool:</a></td>
		<td align=\"right\">#{@book_pool_price}<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_powells}\" target=\"new_window\">Powells:</a></td>
		<td align=\"right\">...<td>
	</tr>
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_online_edition}\" target=\"new_window\">Online Edition 
			<small>(#{@online_edition_type.upcase})</small>:</a></td>
		<td align=\"right\">#{@online_edition_price}<td>
	</tr>
</table>
<br/>
<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
	<tr>
		<td id=\"store\" width=\"175px\"><a href=\"#{@url_bn}\" target=\"new_window\">Brick 'n Mortar:</a></td>
		<td align=\"right\">#{@list_price}<td>
	</tr>
</table>
	</div>
	<br/>
<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
	<tr>
		<td>
			<img class=\"amazonthumbs\" src=\"#{@image_url}\" align=\"left\">
		</td>
		<td width=\"5px\"></td>
		<td valign=\"top\">
			<small><b>#{@title}</b><br/>#{@author}</small>
		</td>
	</tr>
</table>
	</body>
</html>"

else print "
	<div id=\"content\">
<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
	<tr>
		<form name=\"isbn\" method=\"POST\" action=\"http://timeinavacuum.dev/cgi-bin/fold/ears.rb\">
		<td id=\"form\" valign=\"top\" width=\"100px\">ISBN:</td>
		<td id=\"form\" align=\"right\">
			<input type=\"text\" id=\"url\" name=\"url\" size=\"23\"><br/>
			<input type=\"submit\" id=\"search\" name=\"search\" value=\"find\"
						onclick='this.value=\"finding prices...\";'>
		<td>
	</tr>
</table>
	</div>
<p><small>Looking for a book? Find the best price. If you have an isbn number handy, you can type it into the text field and I will tell you what the lowest price is.<br/><br/><a href=\"http://timeinavacuum.dev/foldingears/\">FoldingEars.com</a></small></p>
	</body>
</html>"

end
