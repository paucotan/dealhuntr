require 'faker'

puts "Cleaning up database..."
ShoppingList.destroy_all
Favourite.destroy_all
Deal.destroy_all
Product.destroy_all
Store.destroy_all
User.destroy_all
puts "Database cleaned!"

p "seeding database..."
# Seed Stores
puts "Seeding Stores with logos..."
stores_data = [
  { name: "Albert Heijn", location: Faker::Address.full_address, website_url: "https://www.ah.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Albert_Heijn_Logo.svg/1956px-Albert_Heijn_Logo.svg.png" },
  { name: "Jumbo", location: Faker::Address.full_address, website_url: "https://www.jumbo.com", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Jumbo_Logo.svg/1000px-Jumbo_Logo.svg.png" },
  { name: "Vomar", location: Faker::Address.full_address, website_url: "https://www.vomar.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Vomar-logo.jpg/800px-Vomar-logo.jpg" },
  { name: "Lidl", location: Faker::Address.full_address, website_url: "https://www.lidl.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Lidl-Logo.svg/640px-Lidl-Logo.svg.png" }
]

stores = stores_data.map { |store| Store.create!(store) } # Store created records in `stores`
puts "✅ Created #{stores.count} stores"

#Seed One User
user1 = User.create!(
  name: Faker::Name.name,
  email: "user1@example.com",
  password: "password123"
)
puts "✅ Created 1 user"


# Seed Products
products = []
10.times do
  products << Product.create!(
    name: Faker::Food.ingredient,
    category: Faker::Food.ethnic_category,
    image_url: "https://images.unsplash.com/photo-1615486171815-2611a6e3cd02?q=80&w=3880&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
  )
  end
  puts "✅ Created #{products.count} products"

  # Seed Deals
  deals = []
  20.times do
    product = products.sample
    store = stores.sample
    price = rand(5..50)
    discounted_price = price - rand(1..5)

    deals << Deal.create!(
      price: price,
      discounted_price: discounted_price,
      expiry_date: Faker::Date.forward(days: 30),
      product: product,
      store: store
    )
  end
  puts "✅ Created #{deals.count} deals"

  puts "Seeding completed successfully! 🎉"
