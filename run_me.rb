require "./db_sample_data.rb"

class ConsoleApp
  
  def initialize
    @current_user = Customer.new
    @current_user.customer_login = 'N/A'
    @current_user.customer_password = 'N/A'
    @current_user.customer_name = 'N/A'
    @current_user.customer_surname = 'N/A'
    @current_user.customer_last_name = 'N/A'
    @current_user.mobile_phone_main = 'N/A'
    @current_user.mobile_phone_second = 'N/A'
    @current_user.email = 'N/A'
  end
  
  def help
    puts '"login" - create choise in users'
    puts '"clear" - clear screen'
    
  end
  def clear
    system("clear")
  end
  
  def menu
  
      puts '----------------------------------'
      puts 'Menu'
      puts '----------------------------------'
      menu = ['0 -> Add Sample data' ,'1 -> Login','2 -> Bikes count','3 -> Create booking']
    
      menu.each{|x| puts x} 
    
    
    puts '----------------------------------'
    
    puts 'How are you?' if  @current_user.customer_id.nil?
    
    puts 'id: ' + @current_user.customer_id.to_s
    puts 'login: ' + @current_user.customer_login
    puts 'Name:' + @current_user.customer_name + ' ' + @current_user.customer_surname.first + ' ' + @current_user.customer_last_name
    puts 'mobile phone:' + @current_user.mobile_phone_main  
    puts '----------------------------------'
  end
   
  def login
    tp Customer.where('customer_login<>?','N/A'), :customer_id,:customer_login,:customer_name,:customer_last_name
    
    puts 'Where yours ID or ( -1 for exit) :'
    
    begin     
      input = gets.chomp
      input = input.to_i
    end while Customer.find_by(customer_id: input).nil?  and input != -1
    
    @current_user = Customer.find(input) if input != -1
      
  end 
  
end
  
  
application = ConsoleApp.new
application.clear
i=0
loop do
  
  if i>2 then 
     application.clear
     i=0
  end   
  
  application.menu
  
   
  
  puts 'Command ("help" - for help):'
  input = gets.chomp
  command, *params = input.split /\s/
  
  case command
    when '0'
      SampleData.addSchema
    when '1'
      SampleData.addData
    when '2'
      application.login  
    when '3'
      puts 'We have : '
        BikeState.all.each{|bs| puts bs.bike_state_name + ' : ' + Bike.state(bs.bike_state_code).count.to_s + ' bikes'}  
    when 'menu'
      App.menu  
    when 'clear'
      application.clear
      i=0
    when 'login'
      application.login  
    when 'help'
      application.help  
    else
      puts 'Invalid command ("help" for help)'
    end 
    
    i=i+1
  
end