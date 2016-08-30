$stdout.sync = true

(1..Float::INFINITY).each do
  $stdout.puts "Doing some work..."
  sleep 5
end