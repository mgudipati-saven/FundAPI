#!/usr/bin/env ruby

$infile = ARGV[0]
$outfile = "#{$infile}"

if $infile && File.exist?($infile)
  $outfile = "new-#{$infile}"
  File.open( $outfile, 'w' ) do |f| 
    File.foreach( $infile, "r:windows-1251:utf-8" ) do |line|
      p line
      line1 = line.chomp.gsub(/\"/, '""')
      line2 = line1.gsub(/\|/, '"|"')
      f.puts( '"'+line2+'"'  )
    end
  end
end
