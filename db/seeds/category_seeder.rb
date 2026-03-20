# db/seeds/category_seeder.rb

categories = [
  { name: 'appetizer', description: 'Makanan pembuka / appetizer' },
  { name: 'main', description: 'Makanan utama / main course' },
  { name: 'dessert', description: 'Makanan penutup / dessert' },
  { name: 'drink', description: 'Minuman / beverages' }
]

categories.each do |attrs|
  category = Category.find_or_create_by(name: attrs[:name]) do |c|
    c.description = attrs[:description]
  end
  puts "Category #{category.name} #{category.persisted? ? 'found' : 'created'}"
end