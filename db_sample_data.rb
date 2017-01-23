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
puts '       Available Types'
puts '------------------------'
bc = BikeType.all
tp bc

#Vals
vals = [
['eur','EUR'],
['chf','CHF']
]

vals.each{ |c|
  if !Val.exists?(:currency_code => c[0])
    bc = Val.new
    bc.currency_code = c[0]
    bc.currency_name = c[1]
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
  ['N/A','N/A','Vladimir','Alexandrovich','Schuka','+79022535754','','vladimirschuka@gmail.com'],
  ['vladimirschuka','pass1234','Vladimir','Alexandrovich','Schuka','+79022535754','','vladimirschuka@gmail.com'],
  ['dmitrii','pass1234','Dmitry','','Schuka','+798878998796','','mnbm@gmail.com'],
  ['scvbnm','pass1234','SomeOne','','LastName','+79022538987','','someone@gmail.com'],
  ['oneclient','pass1234','Clients','','Clients2','+79992535754','','clients@gmail.com'],
]


customers.each{ |c|
  if !Customer.exists?(:customer_login => c[0]) 
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

#Customers_Groups
customers_groups = [
  ['vip','VIP clients','VIP clients'],
  ['oneyear','One year','Clients that have more then one year expirience work with our company'],
  ['good','Good clients','Clients those using often the our bikes (more then one times month (average from half year)) ']
]


customers_groups.each{ |c|
  if !CustomersGroup.exists?(:customer_group_code => c[0])
    bc = CustomersGroup.new
    bc.customer_group_code = c[0]
    bc.customer_group_name = c[1]
    bc.customer_group_dscr = c[2]
    bc.save
  end  
}
puts '------------------------'
puts '       Available CustomersGroups'
puts '------------------------'
bc = CustomersGroup.all
tp bc

#Customers_Groups_Membership

customers_groups_membership = [
  ['2000-01-01','2100-01-01','piterparker','vip'],
  ['2000-01-01','2100-01-01','piterparker','oneyear'],
  ['2000-01-01','2100-01-01','vladimirschuka','good'],
  ['2000-01-01','2100-01-01','vladimirschuka','good'],
  ['2000-01-01','2100-01-01','scvbnm','oneyear'],
  ['2000-01-01','2100-01-01','oneclient','good'],
  ['2000-01-01','2100-01-01','oneclient','vip'] 
]


customers_groups_membership.each{ |c|
  if !CustomersGroupsMembership.exists?(:beg_date => c[0] , 
                                        :customer_id => Customer.where(customer_login:  c[2]).first.customer_id ,
                                        :customer_group_id => CustomersGroup.where(customer_group_code:  c[3]).first.customer_group_id)
    bc = CustomersGroupsMembership.new
    bc.beg_date = c[0]
    bc.end_date = c[1]
    bc.customer_id = Customer.where(customer_login:  c[2]).first.customer_id
    bc.customer_group_id = CustomersGroup.where(customer_group_code:  c[3]).first.customer_group_id
    bc.save
  end  
}
puts '------------------------'
puts '       Available CustomersGroupsMembership'
puts '------------------------'
bc = CustomersGroupsMembership.all
tp bc


#Dict_Bikes_models


BikeBrand.all.each do |bb|
  BikeColor.all.each do |bcl|
    BikeType.all.each do |bt|
      
      bc = BikeModel.new
      bc.bike_model_code = bb.brand_code + '_' + bcl.bike_color_code + '_' + bt.bike_type_code
      bc.bike_model_name = bb.brand_name + ' ' + bcl.bike_color_name + ' ' + bt.bike_type_name
      bc.bike_model_brand_id = bb.brand_id
      bc.bike_model_type_id = bt.bike_type_id
      bc.bike_model_color_id = bcl.bike_color_id
      bc.bike_model_speed_count = 18
      bc.bike_model_wheel_size_inch = 26
      bc.bike_model_weight_kg = 10
      bc.bike_model_year = [2014,2015,2016].sample
      bc.bike_model_folding_flag = [0,1].sample
      bc.bike_model_prof_flag = [0,1].sample
      if !BikeModel.exists?(:bike_model_code => bb.brand_code+'_'+bcl.bike_color_code+'_'+bt.bike_type_code)
        bc.save
      end  
  end
 end
end  
    
  

puts '------------------------'
puts '       Available Bikemodel'
puts '------------------------'
bc = BikeModel.all
tp bc



#Booking State

states = [
  ['new','New',100,'0'],
  ['canceled','Canceled',250,'1'],
  ['confirmed','Confirmed',200,'0'],
  ['completed','Completed',300,'1']
  
]

states.each do |c|
  if !BookingState.exists?(:booking_state_code => c[0])
    bc = BookingState.new
    bc.booking_state_code = c[0]
    bc.booking_state_name = c[1]
    bc.booking_state_order = c[2]
    bc.booking_state_last_flag = c[3]
    bc.save
  end 
end

puts '------------------------'
puts '       Available Booking State'
puts '------------------------'
bc = BookingState.all
tp bc

#PricesPlan

priceplan = [
  ['base','Base price plan','This is main price for bike.',1],
  ['vip','Discount for VIP','This is discount for VIP costomers',1],
  ['holiday','Discount for Holiday','Discount for holidays.',0],
  ['count5', 'Discount for 5 bike','If customer booking 5 bikes.',0],
  ['period10','Discount for 10 days','If customer have booking for 10 days ',0]
]

priceplan.each do |c|
  if !PricesPlan.exists?(:price_code => c[0])
    bc = PricesPlan.new
    bc.price_code = c[0]
    bc.price_name = c[1]
    bc.price_dscr = c[2]
    bc.price_sum_flag = c[3]
    bc.save
  end 
end

puts '------------------------'
puts '       Available Booking State'
puts '------------------------'
bc = PricesPlan.all
tp bc


#Prices
periods = [
  ['01.01.2000','01.06.2016'],
  ['01.06.2016','01.09.2016'],
  ['01.09.2016','01.01.2017'],
  ['01.01.2017','01.01.2100']
]

BikeModel.all.each do |bm|
  periods.each do |pr|
    Val.all.each do |vl|
        if !PricesBasePlan.exists?(:beg_date => Date.parse(pr[0]) , 
                                   :bike_model_id => bm.bike_model_id,
                                   :currency_id => vl.currency_id)
        bc = PricesBasePlan.new
        bc.price_plan_id = PricesPlan.where(:price_code => 'base').first.id
        bc.beg_date = Date.parse(pr[0]) 
        bc.end_date = Date.parse(pr[1]) - 1.second
        bc.bike_model_id = bm.bike_model_id
        bc.currency_id = vl.currency_id
        bc.price = rand(5)+10  
        bc.save
      end
    end
  end  
end

puts '------------------------'
puts '       Available BasePrices'
puts '------------------------'
bc = PricesBasePlan.all
tp bc


#dates_Sample_date

AR.connection.execute ("
with recursive x(n) as (
select date'2015-01-01' n 
union all
select n+ 1 n  from x where n <= date'2030-01-01'
)
insert into dict_dates
(sys_date)
select n 
from x where not exists(select 1 from dict_dates where sys_date=n)
")

AR.connection.execute ("
update dict_dates
set holiday_flag = '1'
where  extract(isodow from sys_date::timestamp) in (6,7)
")






















