
require 'rubygems'
require 'pg'
require 'active_record'
require 'yaml'
require 'table_print'


dbparams = YAML.load_file('dbconfig/config.yml')['dbconfiguration']

ActiveRecord::Base.establish_connection(
  :adapter => dbparams['adapter'],
  :host => dbparams['host'],
  :database => dbparams['database'],
  :username => dbparams['username'],
  :password => dbparams['password']
)

class BikeBrand < ActiveRecord::Base
  self.table_name = 'dict_bike_brands'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'brand_id', :foreign_key => 'bike_model_brand_id'
end

class BikeColor < ActiveRecord::Base
  self.table_name = 'dict_bike_colors'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_color_id', :foreign_key => 'bike_model_color_id'
end

class BikeState < ActiveRecord::Base
  self.table_name = 'dict_bike_states'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_state_id', :foreign_key => 'bike_model_current_state_id'
end

class BikeType < ActiveRecord::Base
  self.table_name = 'dict_bike_types'
  has_many :bikemodel, :class_name => 'BikeModel', :primary_key => 'bike_type_id', :foreign_key => 'bike_model_type_id'
end

class BikeModel < ActiveRecord::Base
  self.table_name = 'dict_bike_models'
  belongs_to :bikebrand , :class_name => 'BikeBrand', :primary_key => 'brand_id', :foreign_key => 'bike_model_brand_id'
  belongs_to :bikecolor , :class_name => 'BikeColor', :primary_key => 'bike_color_id', :foreign_key => 'bike_model_color_id'
  belongs_to :bikestate , :class_name => 'BikeState', :primary_key => 'bike_state_id', :foreign_key => 'bike_model_current_state_id'
  belongs_to :biketype , :class_name => 'BikeType', :primary_key => 'bike_type_id', :foreign_key => 'bike_model_type_id'
  
end

class Val <ActiveRecord::Base
  self.table_name = 'dict_vals'
end


class Customer<ActiveRecord::Base
  self.table_name = 't_customers'
end

class CustomersGroup<ActiveRecord::Base
  self.table_name = 't_customers_groups'
end

class CustomersGroupsMembership<ActiveRecord::Base
  self.table_name = 't_customers_groups_membership'
end



