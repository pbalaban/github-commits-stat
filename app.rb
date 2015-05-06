require './env'

puts "Please enter github usernames separated by comma:"
puts CommitCounter.new(gets.chomp).formatted_results
