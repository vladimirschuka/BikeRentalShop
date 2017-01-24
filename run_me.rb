require "./db_sample_data.rb"




class App
  def self.menu
    system("clear")
    puts '----------------------------------'
    puts 'Menu'
    puts '----------------------------------'
    menu = ['0 -> Add Sample data' ,'1 -> Bikes count','2 -> Create booking']
    menu.each{|x| puts x}
    puts '----------------------------------'
    puts 'Command:'
  end 
  
  def self.hello
    puts "hello to you too"
  end
  
   
end

App.menu

loop do
  input = gets.chomp
  command, *params = input.split /\s/
  case command
    when '0'
      SampleData.addData
    when '1'
      puts 'We have : '
        BikeState.all.each{|bs| puts bs.bike_state_name + ' : ' + Bike.state(bs.bike_state_code).count.to_s + ' bikes'}  
    when 'menu'
      App.menu  
    else
      puts 'Invalid command (command "menu" for menu)'
  end 
end