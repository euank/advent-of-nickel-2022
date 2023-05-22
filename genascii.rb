#!/usr/bin/env ruby

lines = (0..127).map{|c|
  "\"\\x#{c.to_s(16).rjust(2, "0")}\" = #{c},"
}

puts "{\n\t#{lines.join("\n\t")}\n}"
