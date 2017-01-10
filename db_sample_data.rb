require "./db_model.rb"

# Colors
colors = [
  ['black','Black'],
  ['white','White'],
  ['red','Red'],
  ['yellow','Yellow'],
  ['blue','Blue'],
  ['green','Green']
]

colors.each{ |c|
  if !BikeColor.exists?(:bike_color_code => c[0])
    bc = BikeColor.new
    bc.bike_color_code = c[0]
    bc.bike_color_name = c[1]
    bc.save
  end  
}
puts '------------------------'
puts '       Available Colors'
puts '------------------------'
bc = BikeColor.all
tp bc

# Brands
brands = [
  ['giant','Giant','Giant Manufacturing Co. Ltd. is a Taiwanese bicycle manufacturer that is recognized as the world''s largest bicycle manufacturer.',true,'Taiwan'],
  ['trek','Trek','Trek Bicycle Corporation is a major bicycle and cycling product manufacturer and distributor under brand names Trek, Electra Bicycle Company, Gary Fisher, Bontrager, Diamant Bikes, Villiger Bikes and until 2008, LeMond Racing Cycles and Klein.',true,'USA'],
  ['btwin','B''Twin','DECATHLON CYCLE WAS REBORN AS B’TWIN. By changing its name in the same year as it celebrated its 20th birthday, the brand now had the means to reach its ambition: to become THE favourite brand amongst cyclists.', true,'France'],
  ['forward','Forward','One of most popular bikes in Russia',false,'Russia']
]

brands.each{ |c|
  if !BikeBrand.exists?(:brand_code => c[0])
    bc = BikeBrand.new
    bc.brand_code = c[0]
    bc.brand_name = c[1]
    bc.brand_dscr = c[2]
    bc.brand_prof_flag = c[3]
    bc.brand_country = c[4]
    bc.save
  end  
}
puts '------------------------'
puts '       Available Brands'
puts '------------------------'
bc = BikeBrand.all
tp bc

#States
states = [
['work','Work'],
['broken','Broken'],
['onservice','On service'],
['eol','End of life'],
['using','Clients using']
]

states.each{ |c|
  if !BikeState.exists?(:bike_state_code => c[0])
    bc = BikeState.new
    bc.bike_state_code = c[0]
    bc.bike_state_name = c[1]
    bc.save
  end  
}
puts '------------------------'
puts '       Available States'
puts '------------------------'
bc = BikeState.all
tp bc

#Types
types = [
['mountain','Mountain bike'],
['road','Road bike'],
['bmx','BMX bike'],
['other','Other bike'],
['child','For children'],
]

types.each{ |c|
  if !BikeType.exists?(:bike_type_code => c[0])
    bc = BikeType.new
    bc.bike_type_code = c[0]
    bc.bike_type_name = c[1]
    bc.save
  end  
}
puts '------------------------'
puts '       Available States'
puts '------------------------'
bc = BikeType.all
tp bc

#Vals
vals = [
['eur','EUR'],
['chf','CHF']
]

vals.each{ |c|
  if !Val.exists?(:val_code => c[0])
    bc = Val.new
    bc.val_code = c[0]
    bc.val_name = c[1]
    bc.save
  end  
}
puts '------------------------'
puts '       Available Vals'
puts '------------------------'
bc = Val.all
tp bc

#Customers
customers = [
  ['piterparker','password1','Piter','','Parker','+4123456789','','spider_man@gmail.com'],
  ['N/A','N/A','Clark','','Kent','+4123456780','','superman@gmail.com'],
  ['vladimirschuka','pass1234','Vladimir','Alexandrovich','Schuka','+79022535754','','vladimirschuka@gmail.com']
]


customers.each{ |c|
  if !Customer.exists?(:customer_login => c[0]) or c[0]=='N/A'
    bc = Customer.new
    bc.customer_login = c[0]
    bc.customer_password = c[1]
    bc.customer_name = c[2]
    bc.customer_surname = c[3]
    bc.customer_last_name = c[4]
    bc.mobile_phone_main = c[5]
    bc.mobile_phone_second = c[6]
    bc.email = c[7]
    bc.save
  end  
}
puts '------------------------'
puts '       Available Customers'
puts '------------------------'
bc = Customer.all
tp bc

