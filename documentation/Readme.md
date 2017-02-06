#DB model descriptions

![DB ER Diagram](https://github.com/vladimirschuka/BikeRentalShop/blob/master/documentation/diagram.jpg)
#Overview	

This model implements the main entities of the bike rental shop. I have implemented four parts: bikes, customers, bookings, prices as you can see on the ER diagram. This database was modeled according to the OLTP principles. Implementing the model I have used Postgresql as most advanced opensource database and ruby for scripting.
	First I have to tell about the naming conventions. All the objects in the DB have prefixes:

* t_ - tables
* v_ - views
* p_ - procedures
* dict_ - dictionary tables
* PK_ - primary keys
* FK_ - foreign keys
* idx – indexes

All the objects from different logical parts have in the names a defining part.For example _bike_ – for the bikes logical part. 
Also in DB the sequences ‘main’ was created so all rows will have unique identifiers.

#Bikes 
The database model for bikes is defined in 7 tables:

* dict_bike_brands – dictionary of bike brands
* dict_bike_colors – dictionary of bike colors, it’s the most disputable dictionary in this model
* dict_bike_types – dictionary with bike types like mountain, bmx, road etc.
* dict_bike_states – this table is dictionary for the bike’s life cycle (working →  broken → being repaired)
* dict_bike_models – the main table that describe bike models, combining all the properties from above. Prices, bookings and bikes themselves are linked to the bike model dictionary. Of course I understand that this table not a dictionary in a classical understanding, because it has foreign keys referencing other dict’s.
* t_bikes – this table contains all the bikes that the company has. Of course t_bikes has a foreign key referencing model and contains also its price (value), the date of purchase, inventory number and the current state.
* t_bikes_states – the table with the bike state history, you can use this for analytics for example, if you want to analyse expenses or find bad customers that often break bikes.

Comments, open questions, points for discussion or future development:

1. What exactly the model is? E.g. color it is the model’s or bike’s property? 
2. What is “the same” or “similar” model from the point of view or a customer? Which properties should be considered for comparison? This question might come for example if bikes in someone’s booking is broken, do we have another similar bike to offer instead?

#Customers

This is a very simple model, the entity customer with information about clients who do bookings. And the customer's groups that used in pricing. Customers and groups have a relationship many-to-many through t_customers_groups_membership.
* t_customers – information about clients.
* t_customers_groups – dictionary customer groups
* t_customers_groups_membership – the table contains relationship between the customers and the groups. Maybe there is only one interesting and difficult thing which is participation history. We have beg_date and end_date which define the periods. 

Comments, open questions, points for discussion or future development:

1. We have regular customers, that have login and password for authorization. But also we have other customers who don’t authorize in the system, whose login and password is N/A. To resolve this situation, separation authorization and customer information would be better.

#Booking

The core structure in DB is defined by four tables:

* t_booking – containing the booking code, the booking time (when the booking was created), a link to customers through customer_id and the booking state, for tracking the life cycle of the booking.
* t_booking_contents – in this table we have the bike model, the time range and the number of bikes.
* t_booking_orders – the table with facts, where we have the information about actual bikes that customer gets. This table is filled when clients come to shop and get the bikes.
* t_booking_prices – each row in t_booking_contents is priced. When generating the invoice for a customer the price information is aggregated.
* dict_booking_states – a dictionary of the life cycle states

Comments, open questions, points for discussion or future development:

1. Why do we are separate bookings and booking contents? Because one client can order more than one bike model a single booking.
2. Why do we separate booking contents and orders? Because we can have a following situation: a customer has created a booking, but when he comes to get the bike, it may be broken, and the customer gets other similar bike. That’s why booking contents and orders may be not consistent.

Booking pricing is a difficult process itself, because we have standard and discounted prices And after a booking is done those prices can be changed, but this must not affect the bookings that are already submitted. That’s why each item of booking contents must be priced explicitly, not just referencing the table with prices. And in `t_booking_prices` we have implemented this.
Bookings have states (New, Confirmed, Completed, Canceled). Two of them are final states: Completed and Canceled. If the state is Confirmed then prices can’t be changed. When the state is New we can change booking contents. This logic is to be implemented on the application side.

#Prices

Prices the most complicated part of the task. Before describing this I have to explain the main thing. For each bike model we have the base prices, for example: bmx bike – 10 $ per day. for each period of time we can have different base price. Then, we have the specials prices, that are used in different discounting schemes. Of course we can’t implement all possible discounting scenarios with just modeling them in the DB without having any logic in the application. But the current model defines many standard cases. Most typical would be special prices for VIP clients or Christmas discounts. 
 In this model, the logic is defined by 3 tables:

* t_prices – the current base prices for bikes
* dict_prices_discounts – a dictionary with names of special prices
* t_price_special_conditions – the special prices. This table needs mode extended description:
	* price_plan_id – a link to the dictionary discounts
	* beg_date_order and end_date_order – the date range for the time when a booking is created
	* period_beg_date period_end_date – the date range when the special price is in action
	* bike_model_id – a link to the bike model
	* customer_group_id – a link to the customer group 
	* bike_count – a discount on the bike count
	* period_order_in_hour – a minimal length of a booking, after which the special price can be applied, days * 24
	* price_specials_value – relative price, relative to the base price, in % or discount.
	* holiday_flag – boolean flag, set when special prices are applied during weekends and holidays.
* dict_currencies – a dictionary with currencies.

For example, if we want to create a special price for any bike model, for vip clients  when booking is create done march 2017 and for april 2017, regardless of the bikes count and the length of the booking. Discount is 10%
Assuming the ID for the VIP customer group is 1.
The following row should be inserted into the table:

- beg_date_order: 01.03.2017, 
- end_date_order: 31.03.2017, 
- period_beg_date: 01.04.2017, 
- period_end_date: 30.04.2017,
- bike_model_id: NULL (meaning any model),
- customer_group_id: 1,
- bike_count: NULL (any number of bikes),
- period_order_in_hour: NULL (any length or the order),
- price_special_value: 10,
- holiday_flag: null (holidays do not matter).

There is a view in the DB called v_booking_prices. This view calculates the effective prices. And there is another one, human readable - v_bills_example  which can be used to get the idea of the price structure.
This example from DB (partial output from the view v_bills_example) :

 bike_model_name | price_code | Price type |  currency_name | price
 --------------- | ---------- | ---------- | -------------- | ----- 
 Trek Blue Road bike | base | Base price | CHF  | 98 
 Trek Blue Road bike | holiday | Discount for Holiday | CHF | -1.4 
 Trek Blue Road bike | vip | Discount for VIP | CHF | -9.8 
 NULL | TOTAL : |  | CHF | 86.8 
 Trek Blue Road bike | base | Base price | EUR | 77 
 Trek Blue Road bike | holiday | Discount for Holiday | EUR | -1.1 
 Trek Blue Road bike | vip | Discount for VIP | EUR | -7.7 
 NULL | TOTAL : | | EUR | 68.2
 
Formula for calculate the special price (discount):

	Price = (base price) * (-1) *  (special price value) /100 * (bikes count) * (days count)

Comments, open questions, points for discussion or future development:

1. When we create bookings, currency is a property of a booking or a property of a payment? May happen that a client comes to the shop and wants pay in EUR but booking was created in CHF. We can create everytingin one currency and use exchange rates, but current schema is better: you can create base prices in different currencies independently  
2. Not all possible discounts are relative. For fixed discounts in special price we would have to add the currency and a boolean field for fixed or relative price. (for example  – a fixed discount of 10 EUR for each order for VIP customers)

#Application

For describe the application lets see to following scheme:

![Application scheme](https://github.com/vladimirschuka/BikeRentalShop/blob/master/documentation/process_schema.jpg)
