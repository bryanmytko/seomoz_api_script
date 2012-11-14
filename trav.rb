#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'pp'

SLEEP_TIME 11

@upa_bit_flag = '34359738368'	#upa Page Authority bitflag
@pda_bit_flag = '68719476736'	#pda Domain Authority bitflag
@access_id = 'xxxxxxxxxx'
@expires = 'xxxxxxxxxx'
@signature = 'xxxxxxxxxx'

file = File.new( "urls.txt", "r" ) #make file a CL argument later?
output_array = Array.new

def api_request( bit_flag )
  api_request_uri = "http://lsapi.seomoz.com/linkscape/url-metrics/#{@url}?"\
  "Cols=#{bit_flag}"\
  "&AccessID=#{@access_id}"\
  "&Expires=#{@expires}"\
  "&Signature=#{@signature}"
end

def format_response( response )
  response_regex = /\"[a-z]+\":\s([\d\.]+)/
  if response.match( response_regex ).nil?
    print response.to_s #this will show the API error, if ie: we get throttled
    return 'ERROR'
  end
  response.match( response_regex )[1] 
end

file.each_line do |line|
  
  @url = URI.parse( line )
  upa_url =  api_request( @upa_bit_flag )
  pda_url = api_request( @pda_bit_flag )
  
  upa_response = Net::HTTP.get( URI.parse upa_url )
  page_authority = format_response( upa_response )

  print "Page Authority Found For: #{@url.to_s} \nSleeping it off..."
  
  sleep SLEEP_TIME #using free account, 1 request per 10 seconds
  
  pda_response = Net::HTTP.get( URI.parse pda_url )
  domain_authority = format_response( pda_response )
  
  print "Domain Authority Found For: #{@url.to_s} \nSleeping it off..."
  
  sleep SLEEP_TIME 
  
  line_hash = { url: @url, page_authority: page_authority, domain_authority: domain_authority }
  output_array.push( line_hash )
  
  print "-- Finished #{@url.to_s}"
  
end

output = File.open( "output.txt", "w" ) do |f|
  f.write( "URL,Page Authority,Domain Authority\n" )
  output_array.each do |o|
    f.write( "#{o[:url].to_s},#{o[:page_authority]},#{o[:domain_authority]}\n" )
  end
end

print "------------------------------------------------------"
print "-- Program completed successfully!"