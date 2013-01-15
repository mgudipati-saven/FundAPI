#!/usr/bin/env ruby

ARGV.each do |a|
  $infile = "#{a}.txt"
  $outfile = "#{a}.csv"
end

File.open( $outfile, 'w' ) do |f| 
  File.foreach( $infile ) do |line|
    line1 = line.chomp.gsub(/\"/, '""')
    line2 = line1.gsub(/\|/, '"|"')
    f.puts( '"'+line2+'"'  )
  end
end