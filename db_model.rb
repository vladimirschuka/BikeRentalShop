
require 'rubygems'
require 'pg'
require 'active_record'
require 'yaml'
require 'table_print'
require 'Date'


dbparams = YAML.load_file('dbconfig/config.yml')['dbconfiguration']

class AR < ActiveRecord::Base
 
end


AR.establish_connection(
      :adapter => dbparams['adapter'],
      :host => dbparams['host'],
      :database => dbparams['database'],
      :username => dbparams['username'],
      :password => dbparams['password']
    )

class BikeBrand < AR
  self.table_name = 'dict_bike_brands'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'brand_id', :foreign_key => 'bike_model_brand_id'
end

class BikeColor < AR
  self.table_name = 'dict_bike_colors'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_color_id', :foreign_key => 'bike_model_color_id'
end

class BikeState < AR
  self.table_name = 'dict_bike_states'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_state_id', :foreign_key => 'bike_model_current_state_id'
end

class BikeType < AR
  self.table_name = 'dict_bike_types'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_type_id', :foreign_key => 'bike_model_type_id'
end

class BikeModel < AR
  self.table_name = 'dict_bike_models'
  belongs_to :bikebrand , :class_name => 'BikeBrand', :primary_key => 'brand_id', :foreign_key => 'bike_model_brand_id'
  belongs_to :bikecolor , :class_name => 'BikeColor', :primary_key => 'bike_color_id', :foreign_key => 'bike_model_color_id'
  belongs_to :bikestate , :class_name => 'BikeState', :primary_key => 'bike_state_id', :foreign_key => 'bike_model_current_state_id'
  belongs_to :biketype , :class_name => 'BikeType', :primary_key => 'bike_type_id', :foreign_key => 'bike_model_type_id'
  
end

class Val < AR
  self.table_name = 'dict_currencies'
end


class Customer < AR
  self.table_name = 't_customers'
  self.primary_key = 'customer_id'
end

class CustomersGroup < AR
  self.table_name = 't_customers_groups'
  self.primary_key = 'customer_group_id'
end

class CustomersGroupsMembership < AR
  self.table_name = 't_customers_groups_membership'
end

class PricesPlan < AR
  self.table_name = 't_prices_plans'
end

class PricesBasePlan < AR
  self.table_name = 't_prices_base_plans'
end

class BookingState < AR
  self.table_name = 'dict_booking_states'
end

class PricesSpecialsConditions <AR
  self.table_name = 't_prices_specials_conditions'
end




