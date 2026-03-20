# db/seeds/user_seeder.rb
require 'bcrypt'

password = 'password123'
encrypted = BCrypt::Password.create(password)

# Data user yang ingin dibuat
users_data = [
  { email: 'superadmin@resto.com', name: 'Super Admin', role: 'super_admin' },
  { email: 'restaurant_admin1@resto.com', name: 'Admin Resto A', role: 'admin_restaurant' },
  { email: 'restaurant_admin2@resto.com', name: 'Admin Resto B', role: 'admin_restaurant' }
]

# Proses create atau update user
users_data.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])

  if user.new_record?
    # User baru: set semua atribut
    user.name = attrs[:name]
    user.role = attrs[:role]
    user.encrypted_password = encrypted
    user.save!
    puts "Created #{user.role}: #{user.email}"
  else
    # User sudah ada: pastikan atribut sesuai (opsional, bisa diupdate jika perlu)
    # user.update!(name: attrs[:name], role: attrs[:role]) # jika ingin update
    puts "Found existing #{user.role}: #{user.email}"
  end
end

# Jika ingin menampilkan API token (pastikan kolom access_token ada di tabel atau model users)
# User.find_each do |user|
#   puts "#{user.email}: #{user.access_token}"
# end