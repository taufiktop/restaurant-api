require 'faker'

# Pastikan kategori sudah ada (dari seeder sebelumnya)
categories = Category.all
if categories.empty?
  puts "No categories found. Run category seeder first."
  exit
end

# Hapus data lama untuk development (opsional)
Restaurant.destroy_all
MenuItem.destroy_all

# Buat 100 restoran
puts "Creating restaurants..."
100.times do |i|
  restaurant = Restaurant.create!(
    name: Faker::Restaurant.name,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    opening_hours: "08:00",
    closing_hours: "22:00"
  )

  # Setiap restoran punya 5-10 menu items
  rand(5..10).times do
    MenuItem.create!(
      name: Faker::Food.dish,
      description: Faker::Food.description,
      price: Faker::Commerce.price(range: 10.0..100.0),
      is_available: [true, false].sample,
      restaurant: restaurant,
      category: categories.sample
    )
  end

  print "." if (i + 1) % 10 == 0
end

puts "\nDone!"
puts "Created #{Restaurant.count} restaurants and #{MenuItem.count} menu items."