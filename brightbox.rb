require 'sqlite3'
require 'faker'

begin

### Build Database

  db = SQLite3::Database.new "example.db"
  db.execute "CREATE TABLE IF NOT EXISTS Employees(Id INTEGER PRIMARY KEY, Name TEXT, Role TEXT)"
  db.execute "CREATE TABLE IF NOT EXISTS Customers(Id INTEGER PRIMARY KEY, Name TEXT)"
  db.execute "CREATE TABLE IF NOT EXISTS Cars(Id INTEGER PRIMARY KEY, Name TEXT, Year INTEGER, Cost INTEGER)"
  db.execute "CREATE TABLE IF NOT EXISTS Purchases(Id INTEGER PRIMARY KEY, Customer_id INTEGER, Employee_id INTEGER, Car_id INTEGER, Sell_price INTEGER)"

### SEED DATA

role = ["salesman", "salesman", "salesman", "manager"]
car_names = ['Audi','Mercedes','Skoda','Volvo','Bentley','Citroen', 'Hummer']

employees = (1..10).map do |ele|
  [ele, "'#{Faker::Name.name}'", "'#{role.sample}'"]
end


customers = (1..10).map do |ele|
  [ele, "'#{Faker::Name.name}'"]
end

cars = (1..10).map do |ele|
  [ele, "'#{car_names.sample}'", rand(2010..2015), rand(30000...35000) ]
end

purchases = (1..10).map do |ele|
  [ele, employees.sample[0], customers.sample[0], cars.sample[0], rand(35000..38000)]
end

### Insert Data into Database


employees.each do |employee|
  db.execute "INSERT INTO Employees VALUES(#{employee.join(',')})"
end

customers.each do |customer|
  db.execute "INSERT INTO customers VALUES(#{customer.join(',')})"
end

cars.each do |car|
  db.execute "INSERT INTO cars VALUES(#{car.join(',')})"
end

purchases.each do |purchase|
  db.execute "INSERT INTO Purchases VALUES(#{purchase.join(',')})"
end

### Calculate Profit Query

calculate_profit = db.execute "SELECT cars.name, cars.cost, purchases.sell_price, COUNT(purchases.car_id) AS Cars_Sold, SUM(purchases.sell_price - cars.cost) AS Profit
  FROM cars
  INNER JOIN purchases
  ON cars.id = purchases.car_id
  GROUP BY name;"

## Display Results

  profit = calculate_profit.map{|row| row.join("\s")}
  headers = %w(Name Cost Price Number_Sold Profit)
  profit.unshift(headers.join("\s"))
  profit.each{|row| p row}

rescue SQLite3::Exception => e
  puts "Exception occurred"
  puts e

ensure
  db.close if db

end

