require "csv"
require 'date'
require 'time'
require 'google/apis/civicinfo_v2'
require "erb"

#Moving clean zipcode to clean_zipcode method
#def clean_zipcode(zipcode)
    #if zipcode.nil?
        #"00000"
        #elsif zipcode.length < 5
            #zipcode = zipcode.rjust(5, "0")
        #elsif zipcode.length > 5
            #zipcode = zipcode.slice(0..4)
        #else
            #zipcode
    #end
#end

#Refactoring: Making clean_zipcode method more succinct
def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def home_phone(homephone)
    erro_msg = 'Bad Phone number'
    homephone = homephone.delete("^0-9").to_s
    if homephone.length == 11 && homephone[0] == '1'
        homephone = homephone.to_s[1..10]
    elsif homephone.length == 11 && homephone[0] != '1'
        homephone = erro_msg
    elsif homephone.length < 10
        homephone = erro_msg
    end
    #puts homephone
end



def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
          address: zip,
          levels: 'country',
          roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
      rescue
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir("output") unless Dir.exist? "output"
      
        filename = "output/thanks_#{id}.html"
      
        File.open(filename,'w') do |file|
          file.puts form_letter
        end
    end
    
    puts "EventManager initialized."
    
    contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
    
    template_letter = File.read "form_letter.erb"
    erb_template = ERB.new template_letter

    $time_arr = Array.new
    $day_arr = Array.new
    
    contents.each do |row|
        id = row[0]
        name = row[:first_name]
        time = row[:regdate]
        date = DateTime.strptime(time, "%m/%d/%y %H:%M")

        $time_arr.push(date.hour)
        $day_arr.push(date.wday)
      
        zipcode = clean_zipcode(row[:zipcode])
        homephone = home_phone(row[:homephone])
      
        legislators = legislators_by_zipcode(zipcode)
      
        form_letter = erb_template.result(binding)

        save_thank_you_letter(id, form_letter) 
    end


    def target_time(time_arr)
        reg_per_hr = Hash.new(0)
        time_arr.each do |completed_reg|
            reg_per_hr[completed_reg] += 1
        end
        reg_per_hr.key(reg_per_hr.values.max)
    end

    def target_wkday(day_arr)
        reg_in_day = Hash.new(0)
        day_arr.each do |completed_reg|
            reg_in_day[completed_reg] += 1
        end
        reg_in_day.key(reg_in_day.values.max)
    end

    def target_day_and_time()
        high_reg_day = target_wkday($day_arr)
        high_reg_time = target_time($time_arr)
        wkday = Date::DAYNAMES[high_reg_day]
        puts "Day of the week with highest registration trafic is #{wkday}"
        puts "Time of the day with highest registration trafic is #{high_reg_time}00 hours"
    end
    

    puts target_day_and_time()



=begin begin
     contents.each do |row|
        name = row[:first_name]
      
        zipcode = clean_zipcode(row[:zipcode])
      
        legislators = legislators_by_zipcode(zipcode)
      
        form_letter = erb_template.result(binding)
        puts form_letter
      end
      

  legislators = civic_info.representative_info_by_address(
                                address: zip,
                                levels: 'country',
                                roles: ['legislatorUpperBody', 'legislatorLowerBody'])
  legislators = legislators.officials
  legislator_names = legislators.map(&:name)
  legislator_names.join(", ")
rescue
  "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
end
end

puts "EventManager initialized."


contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

contents.each do |row|
name = row[:first_name]

zipcode = clean_zipcode(row[:zipcode])

legislators = legislators_by_zipcode(zipcode)

puts "#{name} #{zipcode} #{legislators}"
end

template_letter = File.read "form_letter.html"

contents.each do |row|
    name = row[:first_name]
  
    zipcode = clean_zipcode(row[:zipcode])
  
    legislators = legislators_by_zipcode(zipcode)
  
    personal_letter = template_letter.gsub('FIRST_NAME',name)
    personal_letter.gsub!('LEGISLATORS',legislators)
  
    puts personal_letter
end 
    zipcode = row[:zipcode]
clean zipcode
    if zipcode = nil?
        "00000"
    elsif zipcode.length < 5
        zipcode = zipcode.rjust 5, "0"
    elsif zipcode.length > 5
        zipcode = zipcode.slice(0..4)
    

    begin

    legislators = civic_info.representative_info_by_address(
        address: zipcode,
        levels: "country",
        roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
    legislators_name = legislators.map(&:name).join(',')
    legislators_str = legislators_name.join(',')
    rescue
        "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
    end


lines = File.readlines "event_attendees.csv"
lines.each do |line|
    columns = line.split(",")
    name = columns[2]
    p name
end

lines = File.readlines "event_attendees.csv"
lines.each_with_index do |line, idx|
    next if idx == 0
    columns = line.split(",")
    name = columns[2]
    puts name
end
contents = CSV.open "event_attendees.csv", headers: true
contents.each do |row|
    name = row[2]
    puts name
end
=end

