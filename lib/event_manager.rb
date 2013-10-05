require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end	


def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end   


def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end


def time_tracker(hours)
	hours.sort.uniq.each do |hour|
		puts "Hour " + hour.to_s + ": " + hours.count(hour).to_s
	end
end

def day_tracker(days_of_the_week)
	days_of_the_week.uniq.each do |day|
		puts "Day " + day.to_s + ": " + days_of_the_week.count(day).to_s
	end
end

def clean_home_phone(phonenumber)
	phonenumber = phonenumber.to_s
	phonenumber.gsub! ")",""
	phonenumber.gsub! "(",""
	phonenumber.gsub! "-",""
	phonenumber.gsub! ".",""
	phonenumber.gsub! " ",""

	if phonenumber.length == 10
		phonenumber
	elsif phonenumber.length == 11 && phonenumber [0] == "1"
		phonenumber [1..10]
	else
		"bad number"
	end
end


puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hours = []
days_of_the_week = []

contents.each do |row|
  id = row[0]

  date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")

  name = row[:first_name]

  homephone = row[:homephone]

  zipcode = clean_zipcode(row[:zipcode])
  
  legislators = legislators_by_zipcode(zipcode)

  clean_number = clean_home_phone(homephone)

  times = time_tracker(hours)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)

  hours << date.hour
  days_of_the_week << date.strftime("%A")
end

puts "Time Targeting Report"
time_tracker(hours)

puts "Day Tracking Report"
day_tracker(days_of_the_week)

puts "EventManager Complete"
