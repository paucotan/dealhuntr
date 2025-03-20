require 'faker'

puts "Cleaning up database..."
ShoppingList.destroy_all
Favourite.destroy_all
Deal.destroy_all
Product.destroy_all
Store.destroy_all
User.destroy_all
puts "Database cleaned!"

puts "Seeding database..."
# Seed Stores
stores_data = [
  { name: "Albert Heijn", location: "Provincialeweg 11, 1506 MA Zaandam, Netherlands", website_url: "https://www.ah.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Albert_Heijn_Logo.svg/1956px-Albert_Heijn_Logo.svg.png" },
  { name: "Jumbo", location: "Rijksweg 15, 5462 CE Veghel, Netherlands", website_url: "https://www.jumbo.com", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Jumbo_Logo.svg/1000px-Jumbo_Logo.svg.png" },
  { name: "Vomar", location: "Kaaikhof 13, 1567 JP Assendelft, Netherlands", website_url: "https://www.vomar.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Vomar-logo.jpg/800px-Vomar-logo.jpg" },
  { name: "Lidl", location: "Hullenbergweg 2, 1101 BL Amsterdam, Netherlands", website_url: "https://www.lidl.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Lidl-Logo.svg/640px-Lidl-Logo.svg.png" }
]

stores = stores_data.map { |store| Store.create!(store) }
puts "✅ Created #{stores.count} stores"

# Seed User
user1 = User.create!(
  name: "Jan de Vries",
  email: "user1@example.com",
  password: "password123"
)
puts "✅ Created 1 user"

# Define categories (full list for reference, but we’ll seed key ones first)
categories = [
  "Fruits & Vegetables", "Ready Meals", "Meat & Fish", "Cheese", "Dairy & Eggs", "Bakery",
  "Snacks & Sweets", "Pasta, Rice & International", "Canned Goods & Condiments",
  "Breakfast & Spreads", "Frozen Foods", "Coffee & Tea", "Beverages", "Alcohol",
  "Drugstore", "Household", "Baby Products", "Non-Food", "Seasonal", "Online Only"
]

# Seed Products and Deals
products = []
deals = []
puts "Seeding Products and Deals..."

ah, jumbo, vomar, lidl = stores
deal_types = ["1 voor 9.99", "1+1 gratis", "30% korting", "2+2 gratis", "20% korting"]

# Define all categories (2 products per store, 8 products per category)
product_definitions = {
  "Fruits & Vegetables" => [
    { name: "AH Broccoli", image_url: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?q=80&w=1801&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah },
    { name: "Jumbo Broccoli", image_url: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?q=80&w=1801&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Broccoli", image_url: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?q=80&w=1801&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Broccoli", image_url: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?q=80&w=1801&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  store: lidl },
    { name: "AH Verse Appels", image_url: "https://images.unsplash.com/photo-1623815242959-fb20354f9b8d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah },
    { name: "Jumbo Verse Appels", image_url: "https://images.unsplash.com/photo-1623815242959-fb20354f9b8d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Verse Appels", image_url: "https://images.unsplash.com/photo-1623815242959-fb20354f9b8d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Verse Appels", image_url: "https://images.unsplash.com/photo-1623815242959-fb20354f9b8d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: lidl },
    { name: "AH Wortelen", image_url: "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah },
    { name: "Jumbo Wortelen", image_url: "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Wortelen", image_url: "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Wortelen", image_url: "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: lidl }
  ],
  "Meat & Fish" => [
    { name: "AH Kipfilet", image_url: "https://static.ah.nl/dam/product/AHI_4354523130303937373135?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: ah },
    { name: "Jumbo Kipfilet", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/12122024_1734017700588_1734017707185_2378607000000_1.png", store: jumbo },
    { name: "Vomar Kipfilet", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SCHARRELKIPFILET-2-O-S-2394040000000-0-638368473858399987.jpg", store: vomar },
    { name: "Lidl Kipfilet", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SCHARRELKIPFILET-2-O-S-2394040000000-0-638368473858399987.jpg", store: lidl },
    { name: "AH Zalmfilet", image_url: "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah },
    { name: "Jumbo Zalmfilet", image_url: "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Zalmfilet", image_url: "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Zalmfilet", image_url: "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: lidl }
  ],
  "Dairy & Eggs" => [
    { name: "AH Volle Melk", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/-Zuivelmeester-Halfvolle-Melk-2-L-8710624326364-1-637957265105713936.png", store: ah },
    { name: "Jumbo Volle Melk", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/-Zuivelmeester-Halfvolle-Melk-2-L-8710624326364-1-637957265105713936.png", store: jumbo },
    { name: "Vomar Volle Melk", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/-Zuivelmeester-Halfvolle-Melk-2-L-8710624326364-1-637957265105713936.png", store: vomar },
    { name: "Lidl Volle Melk", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/-Zuivelmeester-Halfvolle-Melk-2-L-8710624326364-1-637957265105713936.png", store: lidl },
    { name: "AH Scharreleieren", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Scharreleieren-Klasse-A-10-Stuks-8710624346232-1-637641864854972461.png", store: ah },
    { name: "Jumbo Scharreleieren", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Scharreleieren-Klasse-A-10-Stuks-8710624346232-1-637641864854972461.png", store: jumbo },
    { name: "Vomar Scharreleieren", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Scharreleieren-Klasse-A-10-Stuks-8710624346232-1-637641864854972461.png", store: vomar },
    { name: "Lidl Scharreleieren", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Scharreleieren-Klasse-A-10-Stuks-8710624346232-1-637641864854972461.png", store: lidl }
  ],
  "Bakery" => [
    { name: "AH Wit Brood", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/RD-VOMAR-ROND-WIT-HEEL-2250840000000-0-638276891632919723.jpg", store: ah },
    { name: "Jumbo Wit Brood", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/RD-VOMAR-ROND-WIT-HEEL-2250840000000-0-638276891632919723.jpg", store: jumbo },
    { name: "Vomar Wit Brood", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/RD-VOMAR-ROND-WIT-HEEL-2250840000000-0-638276891632919723.jpg", store: vomar },
    { name: "Lidl Wit Brood", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/RD-VOMAR-ROND-WIT-HEEL-2250840000000-0-638276891632919723.jpg", store: lidl },
    { name: "AH Croissants", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Roomboter-Croissants-4-x-45-g-8710624214463-1-637957255154361173.png", store: ah },
    { name: "Jumbo Croissants", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Roomboter-Croissants-4-x-45-g-8710624214463-1-637957255154361173.png", store: jumbo },
    { name: "Vomar Croissants", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Roomboter-Croissants-4-x-45-g-8710624214463-1-637957255154361173.png", store: vomar },
    { name: "Lidl Croissants", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Roomboter-Croissants-4-x-45-g-8710624214463-1-637957255154361173.png", store: lidl }
  ],
  "Beverages" => [
    { name: "AH Sinaasappelsap", image_url: "https://imgproxy-retcat.assets.schwarz/VY6NZPqZg4C8j-dTdnh_-yoyL_UblGx8FB3P1wEzIMI/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9CMUM0RjM1QjhCODEwQ0ZERDE3NEU2RTI/4RUU4MUY5OEFGOEVDNzFCRTBGN0VCRTFDN0I0MDU1ODIzNDg2MjY3LmpwZw.jpg", store: ah },
    { name: "Jumbo Sinaasappelsap", image_url: "https://imgproxy-retcat.assets.schwarz/VY6NZPqZg4C8j-dTdnh_-yoyL_UblGx8FB3P1wEzIMI/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9CMUM0RjM1QjhCODEwQ0ZERDE3NEU2RTI/4RUU4MUY5OEFGOEVDNzFCRTBGN0VCRTFDN0I0MDU1ODIzNDg2MjY3LmpwZw.jpg", store: jumbo },
    { name: "Vomar Sinaasappelsap", image_url: "https://imgproxy-retcat.assets.schwarz/VY6NZPqZg4C8j-dTdnh_-yoyL_UblGx8FB3P1wEzIMI/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9CMUM0RjM1QjhCODEwQ0ZERDE3NEU2RTI/4RUU4MUY5OEFGOEVDNzFCRTBGN0VCRTFDN0I0MDU1ODIzNDg2MjY3LmpwZw.jpg", store: vomar },
    { name: "Lidl Sinaasappelsap", image_url: "https://imgproxy-retcat.assets.schwarz/VY6NZPqZg4C8j-dTdnh_-yoyL_UblGx8FB3P1wEzIMI/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9CMUM0RjM1QjhCODEwQ0ZERDE3NEU2RTI/4RUU4MUY5OEFGOEVDNzFCRTBGN0VCRTFDN0I0MDU1ODIzNDg2MjY3LmpwZw.jpg", store: lidl },
    { name: "AH Fleswater", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SPA-REINE-Natuurlijk-Mineraalwater-1l-5410013136149-1-638440417218782936.png", store: ah },
    { name: "Jumbo Fleswater", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SPA-REINE-Natuurlijk-Mineraalwater-1l-5410013136149-1-638440417218782936.png", store: jumbo },
    { name: "Vomar Fleswater", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SPA-REINE-Natuurlijk-Mineraalwater-1l-5410013136149-1-638440417218782936.png", store: vomar },
    { name: "Lidl Fleswater", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SPA-REINE-Natuurlijk-Mineraalwater-1l-5410013136149-1-638440417218782936.png", store: lidl }
  ],
  "Snacks & Sweets" => [
    { name: "AH Aardappelchips", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Naturel-Tortilla-Chips-165-g-8710624266455-1-637957254507948590.png", store: ah },
    { name: "Jumbo Aardappelchips", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Naturel-Tortilla-Chips-165-g-8710624266455-1-637957254507948590.png", store: jumbo },
    { name: "Vomar Aardappelchips", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Naturel-Tortilla-Chips-165-g-8710624266455-1-637957254507948590.png", store: vomar },
    { name: "Lidl Aardappelchips", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Naturel-Tortilla-Chips-165-g-8710624266455-1-637957254507948590.png", store: lidl },
    { name: "AH Chocoladereep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: ah },
    { name: "Jumbo Chocoladereep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: jumbo },
    { name: "Vomar Chocoladereep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: vomar },
    { name: "Lidl Chocoladereep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: lidl }
  ],
  "Ready Meals" => [
    { name: "AH Kip Curry", image_url: "https://plus.unsplash.com/premium_photo-1723579413852-d71dbd8641d2?q=80&w=2036&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah }, # Reuse Kipfilet image
    { name: "Jumbo Kip Curry", image_url: "https://plus.unsplash.com/premium_photo-1723579413852-d71dbd8641d2?q=80&w=2036&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Kip Curry", image_url: "https://plus.unsplash.com/premium_photo-1723579413852-d71dbd8641d2?q=80&w=2036&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Kip Curry", image_url: "https://plus.unsplash.com/premium_photo-1723579413852-d71dbd8641d2?q=80&w=2036&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: lidl },
    { name: "AH Groente Lasagne", image_url: "https://static.ah.nl/dam/product/AHI_4354523130303530323239?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: ah }, # Reuse Wortelen image (vegetable-based)
    { name: "Jumbo Groente Lasagne", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/18012025_1737167997460_1737168055953_505994_DS_08720182017253_C1N1.png", store: jumbo },
    { name: "Vomar Groente Lasagne", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/18012025_1737167997460_1737168055953_505994_DS_08720182017253_C1N1.png", store: vomar },
    { name: "Lidl Groente Lasagne", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/18012025_1737167997460_1737168055953_505994_DS_08720182017253_C1N1.png", store: lidl }
  ],
  "Cheese" => [
    { name: "AH Goudse Kaas", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Jong-Gouda-Kaas-48-200-g-8710866043548-1-637957248734609972.png", store: ah }, # Reuse Volle Melk image (dairy)
    { name: "Jumbo Goudse Kaas", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Jong-Gouda-Kaas-48-200-g-8710866043548-1-637957248734609972.png", store: jumbo },
    { name: "Vomar Goudse Kaas", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Jong-Gouda-Kaas-48-200-g-8710866043548-1-637957248734609972.png", store: vomar },
    { name: "Lidl Goudse Kaas", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Jong-Gouda-Kaas-48-200-g-8710866043548-1-637957248734609972.png", store: lidl },
    { name: "AH Cheddar Blok", image_url: "https://static.ah.nl/dam/product/AHI_43545236393638333132?revLabel=3&rendition=800x800_JPG_Q90&fileType=binary", store: ah },
    { name: "Jumbo Cheddar Blok", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/13112023_1699896782384_1699896792115_8718452695119_1.png", store: jumbo },
    { name: "Vomar Cheddar Blok", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Geraspt-Cheddar-50-150-g-8710866032351-1-637957267211829625.png", store: vomar },
    { name: "Lidl Cheddar Blok", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Geraspt-Cheddar-50-150-g-8710866032351-1-637957267211829625.png", store: lidl }
  ],
  "Pasta, Rice & International" => [
    { name: "AH Spaghetti", image_url: "https://static.ah.nl/dam/product/AHI_4354523130303830363437?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: ah }, # No direct match, leave empty
    { name: "Jumbo Spaghetti", image_url: "https://static.ah.nl/dam/product/AHI_4354523130303830363437?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: jumbo },
    { name: "Vomar Spaghetti", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Casa-Italiana-Spaghetti-1000-g-8710624178628-1-637957238105285747.png", store: vomar },
    { name: "Lidl Spaghetti", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Casa-Italiana-Spaghetti-1000-g-8710624178628-1-637957238105285747.png", store: lidl },
    { name: "AH Jasmijnrijst", image_url: "https://static.ah.nl/dam/product/AHI_43545239363239373931?revLabel=2&rendition=800x800_JPG_Q90&fileType=binary", store: ah },
    { name: "Jumbo Jasmijnrijst", image_url: "https://static.ah.nl/dam/product/AHI_43545239363239373931?revLabel=2&rendition=800x800_JPG_Q90&fileType=binary", store: jumbo },
    { name: "Vomar Jasmijnrijst", image_url: "https://imgproxy-retcat.assets.schwarz/575BPgXBxriTYYx26fzzhoE3LQJdxU_wIEEydDAf43g/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9ENkIwRDg3MzI2N0E2RTJENDFFRUNDMUQ/4NDA1NjQ2QTNFOTlCQUIzNDlCM0JCMEE0NjU5QkM3NkFDMENBQ0Q1LmpwZw.jpg", store: vomar },
    { name: "Lidl Jasmijnrijst", image_url: "https://imgproxy-retcat.assets.schwarz/575BPgXBxriTYYx26fzzhoE3LQJdxU_wIEEydDAf43g/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9ENkIwRDg3MzI2N0E2RTJENDFFRUNDMUQ/4NDA1NjQ2QTNFOTlCQUIzNDlCM0JCMEE0NjU5QkM3NkFDMENBQ0Q1LmpwZw.jpg", store: lidl }
  ],
  "Canned Goods & Condiments" => [
    { name: "AH Tonijn in Blik", image_url: "https://imgproxy-retcat.assets.schwarz/S6P3JYgmVmRrIhcDmwjr_sxx8IBvBmkoK2z_PuX2HnY/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50Lzc5M0JEOUU3MTAyQUVFNzE2QzUyQzc4Qz/EyNDY5MEM5MTdDMUM5OTkyRjU0RDIwOTc2MjExMDRFMDQwNkI1NUQucG5n.png", store: ah }, # No direct match, leave empty
    { name: "Jumbo Tonijn in Blik", image_url: "https://imgproxy-retcat.assets.schwarz/S6P3JYgmVmRrIhcDmwjr_sxx8IBvBmkoK2z_PuX2HnY/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50Lzc5M0JEOUU3MTAyQUVFNzE2QzUyQzc4Qz/EyNDY5MEM5MTdDMUM5OTkyRjU0RDIwOTc2MjExMDRFMDQwNkI1NUQucG5n.png", store: jumbo },
    { name: "Vomar Tonijn in Blik", image_url: "https://imgproxy-retcat.assets.schwarz/S6P3JYgmVmRrIhcDmwjr_sxx8IBvBmkoK2z_PuX2HnY/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50Lzc5M0JEOUU3MTAyQUVFNzE2QzUyQzc4Qz/EyNDY5MEM5MTdDMUM5OTkyRjU0RDIwOTc2MjExMDRFMDQwNkI1NUQucG5n.png", store: vomar },
    { name: "Lidl Tonijn in Blik", image_url: "https://imgproxy-retcat.assets.schwarz/S6P3JYgmVmRrIhcDmwjr_sxx8IBvBmkoK2z_PuX2HnY/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50Lzc5M0JEOUU3MTAyQUVFNzE2QzUyQzc4Qz/EyNDY5MEM5MTdDMUM5OTkyRjU0RDIwOTc2MjExMDRFMDQwNkI1NUQucG5n.png", store: lidl },
    { name: "AH Ketchup", image_url: "https://imgproxy-retcat.assets.schwarz/YKaWrqb6UZl3iDhBdu5w_RPzwY_vRUcaCnJsAQp95LE/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BQThCN0VFNTE5NTcyOTZDMTRFQkQzNUJ/EMzA5NDVEMDg3NUY0QTMzRENEOUE5MjFCMTE4QkZFM0JCOUIzQkU2LmpwZw.jpg", store: ah },
    { name: "Jumbo Ketchup", image_url: "https://imgproxy-retcat.assets.schwarz/YKaWrqb6UZl3iDhBdu5w_RPzwY_vRUcaCnJsAQp95LE/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BQThCN0VFNTE5NTcyOTZDMTRFQkQzNUJ/EMzA5NDVEMDg3NUY0QTMzRENEOUE5MjFCMTE4QkZFM0JCOUIzQkU2LmpwZw.jpg", store: jumbo },
    { name: "Vomar Ketchup", image_url: "https://imgproxy-retcat.assets.schwarz/YKaWrqb6UZl3iDhBdu5w_RPzwY_vRUcaCnJsAQp95LE/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BQThCN0VFNTE5NTcyOTZDMTRFQkQzNUJ/EMzA5NDVEMDg3NUY0QTMzRENEOUE5MjFCMTE4QkZFM0JCOUIzQkU2LmpwZw.jpg", store: vomar },
    { name: "Lidl Ketchup", image_url: "https://imgproxy-retcat.assets.schwarz/YKaWrqb6UZl3iDhBdu5w_RPzwY_vRUcaCnJsAQp95LE/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BQThCN0VFNTE5NTcyOTZDMTRFQkQzNUJ/EMzA5NDVEMDg3NUY0QTMzRENEOUE5MjFCMTE4QkZFM0JCOUIzQkU2LmpwZw.jpg", store: lidl }
  ],
  "Breakfast & Spreads" => [
    { name: "AH Cornflakes", image_url: "https://imgproxy-retcat.assets.schwarz/Lm0A_743B3Bg5vzTaKPoAItc49WtdTYmSQ7xLg8Kt-w/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS83MjAyNzdCNUNDOTJCNjYzREU5N0FBOUN/FMjhENDAwMUZBQTI0N0Q4NkJFOEIwMjlFQTU3REQwRkMzMTFCQUEwLmpwZw.jpg", store: ah }, # No direct match, leave empty
    { name: "Jumbo Cornflakes", image_url: "https://imgproxy-retcat.assets.schwarz/Lm0A_743B3Bg5vzTaKPoAItc49WtdTYmSQ7xLg8Kt-w/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS83MjAyNzdCNUNDOTJCNjYzREU5N0FBOUN/FMjhENDAwMUZBQTI0N0Q4NkJFOEIwMjlFQTU3REQwRkMzMTFCQUEwLmpwZw.jpg", store: jumbo },
    { name: "Vomar Cornflakes", image_url: "https://imgproxy-retcat.assets.schwarz/Lm0A_743B3Bg5vzTaKPoAItc49WtdTYmSQ7xLg8Kt-w/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS83MjAyNzdCNUNDOTJCNjYzREU5N0FBOUN/FMjhENDAwMUZBQTI0N0Q4NkJFOEIwMjlFQTU3REQwRkMzMTFCQUEwLmpwZw.jpg", store: vomar },
    { name: "Lidl Cornflakes", image_url: "https://imgproxy-retcat.assets.schwarz/Lm0A_743B3Bg5vzTaKPoAItc49WtdTYmSQ7xLg8Kt-w/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS83MjAyNzdCNUNDOTJCNjYzREU5N0FBOUN/FMjhENDAwMUZBQTI0N0Q4NkJFOEIwMjlFQTU3REQwRkMzMTFCQUEwLmpwZw.jpg", store: lidl },
    { name: "AH Pindakaas", image_url: "https://static.ah.nl/dam/product/AHI_43545239393838353430?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: ah },
    { name: "Jumbo Pindakaas", image_url: "https://static.ah.nl/dam/product/AHI_43545239393838353430?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: jumbo },
    { name: "Vomar Pindakaas", image_url: "https://imgproxy-retcat.assets.schwarz/Nu7d2AtgQYrVtHhj_8PyDXk5xQ5P0yXbM4gVFJGRVsw/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0FDRDgwNzI3MDAzMjdGMDU5NTE5Nzg0N0/JFNTAxQkFCOTE2RkYyRjA5RjYxRkJCRDUwRUFDMjU4NUZGMkZERTMucG5n.png", store: vomar },
    { name: "Lidl Pindakaas", image_url: "https://imgproxy-retcat.assets.schwarz/Nu7d2AtgQYrVtHhj_8PyDXk5xQ5P0yXbM4gVFJGRVsw/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0FDRDgwNzI3MDAzMjdGMDU5NTE5Nzg0N0/JFNTAxQkFCOTE2RkYyRjA5RjYxRkJCRDUwRUFDMjU4NUZGMkZERTMucG5n.png", store: lidl }
  ],
  "Frozen Foods" => [
    { name: "AH Diepvriespizza", image_url: "https://static.ah.nl/dam/product/AHI_43545239383436303038?revLabel=1&rendition=800x800_JPG_Q90&fileType=binary", store: ah }, # No direct match, leave empty
    { name: "Jumbo Diepvriespizza", image_url: "https://www.jumbo.com/dam-images/fit-in/360x360/Products/26042024_1714127650071_1714127684048_8718452777020_596.png", store: jumbo },
    { name: "Vomar Diepvriespizza", image_url: "https://images.migrosone.com/sanalmarket/product/17555667/17555667-c03827-1650x1650.jpg", store: vomar },
    { name: "Lidl Diepvriespizza", image_url: "https://images.migrosone.com/sanalmarket/product/17555667/17555667-c03827-1650x1650.jpg", store: lidl },
    { name: "AH Roomijs", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Ben-Jerry-s-IJs-Cookie-Dough-100-ml-8711200564149-1-638217504147197387.png", store: ah },
    { name: "Jumbo Roomijs", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Ben-Jerry-s-IJs-Cookie-Dough-100-ml-8711200564149-1-638217504147197387.png", store: jumbo },
    { name: "Vomar Roomijs", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Ben-Jerry-s-IJs-Cookie-Dough-100-ml-8711200564149-1-638217504147197387.png", store: vomar },
    { name: "Lidl Roomijs", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Ben-Jerry-s-IJs-Cookie-Dough-100-ml-8711200564149-1-638217504147197387.png", store: lidl }
  ],
  "Coffee & Tea" => [
    { name: "AH Gemalen Koffie", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Douwe-Egberts-Aroma-Rood-Filterkoffie-250-g-8711000003145-1-637957263472727579.png", store: ah }, # No direct match, leave empty
    { name: "Jumbo Gemalen Koffie", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Douwe-Egberts-Aroma-Rood-Filterkoffie-250-g-8711000003145-1-637957263472727579.png", store: jumbo },
    { name: "Vomar Gemalen Koffie", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Douwe-Egberts-Aroma-Rood-Filterkoffie-250-g-8711000003145-1-637957263472727579.png", store: vomar },
    { name: "Lidl Gemalen Koffie", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Douwe-Egberts-Aroma-Rood-Filterkoffie-250-g-8711000003145-1-637957263472727579.png", store: lidl },
    { name: "AH Groene Theezakjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-Groene-Thee-Citroen-20-x-1-5-g-8710624324261-1-637957261429111159.png", store: ah },
    { name: "Jumbo Groene Theezakjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-Groene-Thee-Citroen-20-x-1-5-g-8710624324261-1-637957261429111159.png", store: jumbo },
    { name: "Vomar Groene Theezakjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-Groene-Thee-Citroen-20-x-1-5-g-8710624324261-1-637957261429111159.png", store: vomar },
    { name: "Lidl Groene Theezakjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-Groene-Thee-Citroen-20-x-1-5-g-8710624324261-1-637957261429111159.png", store: lidl }
  ],
  "Alcohol" => [
    { name: "AH Rode Wijn", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Just-0-Red-Wine-Alcoholfree-0-75-L-4003301069048-1-637957247344440393.png", store: ah }, # New image for red wine
    { name: "Jumbo Rode Wijn", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Just-0-Red-Wine-Alcoholfree-0-75-L-4003301069048-1-637957247344440393.png", store: jumbo },
    { name: "Vomar Rode Wijn", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Just-0-Red-Wine-Alcoholfree-0-75-L-4003301069048-1-637957247344440393.png", store: vomar },
    { name: "Lidl Rode Wijn", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Just-0-Red-Wine-Alcoholfree-0-75-L-4003301069048-1-637957247344440393.png", store: lidl },
    { name: "AH Lager Bier", image_url: "https://imgproxy-retcat.assets.schwarz/Wj4LTSJXn75DmU-7_S3SFjkQY2iLeEbTRrEjMuIp-og/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82QzYwQkE0MjcxNUFEODNFMzM1MURCNDE/5OUZGODdCNTZGNDA4MUIxNDBEMDJDNDFGOEZENzc4NjdDNzNFNzM3LmpwZw.jpg", store: ah }, # Reuse red wine image (close enough for demo)
    { name: "Jumbo Lager Bier", image_url: "https://imgproxy-retcat.assets.schwarz/Wj4LTSJXn75DmU-7_S3SFjkQY2iLeEbTRrEjMuIp-og/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82QzYwQkE0MjcxNUFEODNFMzM1MURCNDE/5OUZGODdCNTZGNDA4MUIxNDBEMDJDNDFGOEZENzc4NjdDNzNFNzM3LmpwZw.jpg", store: jumbo },
    { name: "Vomar Lager Bier", image_url: "https://imgproxy-retcat.assets.schwarz/Wj4LTSJXn75DmU-7_S3SFjkQY2iLeEbTRrEjMuIp-og/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82QzYwQkE0MjcxNUFEODNFMzM1MURCNDE/5OUZGODdCNTZGNDA4MUIxNDBEMDJDNDFGOEZENzc4NjdDNzNFNzM3LmpwZw.jpg", store: vomar },
    { name: "Lidl Lager Bier", image_url: "https://imgproxy-retcat.assets.schwarz/Wj4LTSJXn75DmU-7_S3SFjkQY2iLeEbTRrEjMuIp-og/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82QzYwQkE0MjcxNUFEODNFMzM1MURCNDE/5OUZGODdCNTZGNDA4MUIxNDBEMDJDNDFGOEZENzc4NjdDNzNFNzM3LmpwZw.jpg", store: lidl }
  ],
  "Drugstore" => [
    { name: "AH Pijnstillers", image_url: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: ah }, # No direct match, leave empty
    { name: "Jumbo Pijnstillers", image_url: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: jumbo },
    { name: "Vomar Pijnstillers", image_url: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: vomar },
    { name: "Lidl Pijnstillers", image_url: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", store: lidl },
    { name: "AH Pleisters", image_url: "https://img.fruugo.com/product/8/49/924529498_max.jpg", store: ah },
    { name: "Jumbo Pleisters", image_url: "https://img.fruugo.com/product/8/49/924529498_max.jpg", store: jumbo },
    { name: "Vomar Pleisters", image_url: "https://img.fruugo.com/product/8/49/924529498_max.jpg", store: vomar },
    { name: "Lidl Pleisters", image_url: "https://img.fruugo.com/product/8/49/924529498_max.jpg", store: lidl }
  ],
  "Household" => [
    { name: "AH Keukenpapier", image_url: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSAXIJJPV4q8awSE_El-m9tM9wSlkjyNq7DjWa6ued1l2YQLExEkqarCuO6wazw853PQ6iVRamlRoWn_FRbo1DGWNGNTc5s6qQQ3kvLI-2XMYZ4FZyunZnJ", store: ah }, # No direct match, leave empty
    { name: "Jumbo Keukenpapier", image_url: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSAXIJJPV4q8awSE_El-m9tM9wSlkjyNq7DjWa6ued1l2YQLExEkqarCuO6wazw853PQ6iVRamlRoWn_FRbo1DGWNGNTc5s6qQQ3kvLI-2XMYZ4FZyunZnJ", store: jumbo },
    { name: "Vomar Keukenpapier", image_url: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSAXIJJPV4q8awSE_El-m9tM9wSlkjyNq7DjWa6ued1l2YQLExEkqarCuO6wazw853PQ6iVRamlRoWn_FRbo1DGWNGNTc5s6qQQ3kvLI-2XMYZ4FZyunZnJ", store: vomar },
    { name: "Lidl Keukenpapier", image_url: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSAXIJJPV4q8awSE_El-m9tM9wSlkjyNq7DjWa6ued1l2YQLExEkqarCuO6wazw853PQ6iVRamlRoWn_FRbo1DGWNGNTc5s6qQQ3kvLI-2XMYZ4FZyunZnJ", store: lidl },
    { name: "AH Vuilniszakken", image_url: "https://takeaware.nl/cdn/shop/files/9925020-komo-huisvuilzakken-met-sluitstrip-60x80cm-grijs-1129163810.png?v=1739239902&width=1200", store: ah },
    { name: "Jumbo Vuilniszakken", image_url: "https://takeaware.nl/cdn/shop/files/9925020-komo-huisvuilzakken-met-sluitstrip-60x80cm-grijs-1129163810.png?v=1739239902&width=1200", store: jumbo },
    { name: "Vomar Vuilniszakken", image_url: "https://takeaware.nl/cdn/shop/files/9925020-komo-huisvuilzakken-met-sluitstrip-60x80cm-grijs-1129163810.png?v=1739239902&width=1200", store: vomar },
    { name: "Lidl Vuilniszakken", image_url: "https://takeaware.nl/cdn/shop/files/9925020-komo-huisvuilzakken-met-sluitstrip-60x80cm-grijs-1129163810.png?v=1739239902&width=1200", store: lidl }
  ],
  "Baby Products" => [
    { name: "AH Luiers", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonb-b-Ultra-Zachte-Luiers-Maxi-4-8-16-kg-40-Stuks-8710624280314-1-637957252959183165.png", store: ah }, # No direct match, leave empty
    { name: "Jumbo Luiers", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonb-b-Ultra-Zachte-Luiers-Maxi-4-8-16-kg-40-Stuks-8710624280314-1-637957252959183165.png", store: jumbo },
    { name: "Vomar Luiers", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonb-b-Ultra-Zachte-Luiers-Maxi-4-8-16-kg-40-Stuks-8710624280314-1-637957252959183165.png", store: vomar },
    { name: "Lidl Luiers", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonb-b-Ultra-Zachte-Luiers-Maxi-4-8-16-kg-40-Stuks-8710624280314-1-637957252959183165.png", store: lidl },
    { name: "AH Babydoekjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Huggies-Baby-Cleansing-Wipes-Pure-56-Stuks-5029053550039-1-637957269810293118.png", store: ah },
    { name: "Jumbo Babydoekjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Huggies-Baby-Cleansing-Wipes-Pure-56-Stuks-5029053550039-1-637957269810293118.png", store: jumbo },
    { name: "Vomar Babydoekjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Huggies-Baby-Cleansing-Wipes-Pure-56-Stuks-5029053550039-1-637957269810293118.png", store: vomar },
    { name: "Lidl Babydoekjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Huggies-Baby-Cleansing-Wipes-Pure-56-Stuks-5029053550039-1-637957269810293118.png", store: lidl }
  ],
  "Non-Food" => [
    { name: "AH Batterijen", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Varta-Longlife-Power-Alkaline-9V-4008496559862-1-638044488453107957.png", store: ah }, # No direct match, leave empty
    { name: "Jumbo Batterijen", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Varta-Longlife-Power-Alkaline-9V-4008496559862-1-638044488453107957.png", store: jumbo },
    { name: "Vomar Batterijen", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Varta-Longlife-Power-Alkaline-9V-4008496559862-1-638044488453107957.png", store: vomar },
    { name: "Lidl Batterijen", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Varta-Longlife-Power-Alkaline-9V-4008496559862-1-638044488453107957.png", store: lidl },
    { name: "AH Lampen", image_url: "https://m.media-amazon.com/images/I/71eCn2-T1hL.__AC_SX300_SY300_QL70_ML2_.jpg", store: ah },
    { name: "Jumbo Lampen", image_url: "https://m.media-amazon.com/images/I/71eCn2-T1hL.__AC_SX300_SY300_QL70_ML2_.jpg", store: jumbo },
    { name: "Vomar Lampen", image_url: "https://m.media-amazon.com/images/I/71eCn2-T1hL.__AC_SX300_SY300_QL70_ML2_.jpg", store: vomar },
    { name: "Lidl Lampen", image_url: "https://m.media-amazon.com/images/I/71eCn2-T1hL.__AC_SX300_SY300_QL70_ML2_.jpg", store: lidl }
  ],
  "Seasonal" => [
    { name: "AH Paaschocolade-eieren", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: ah }, # Reuse Chocoladereep image
    { name: "Jumbo Paaschocolade-eieren", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: jumbo },
    { name: "Vomar Paaschocolade-eieren", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: vomar },
    { name: "Lidl Paaschocolade-eieren", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: lidl },
    { name: "AH Halloween Snoep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: ah },
    { name: "Jumbo Halloween Snoep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: jumbo },
    { name: "Vomar Halloween Snoep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: vomar },
    { name: "Lidl Halloween Snoep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp", store: lidl }
  ],
  "Online Only" => [
    { name: "AH Speciale Olijfolie", image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcS5KZARLZiKXM9PwwKZLGwdmf4cdSBnnQ1Hni4s6gERUlh7MDw7qFPenuFT37EE0CX7Uio9t0hSq0wHQrNd3gC7-oKcPcMWLfnpbpaZMef2KneaIOq7NrQtAbl7bGT1wHQdlA&usqp=CAc", store: ah }, # No direct match, leave empty
    { name: "Jumbo Speciale Olijfolie", image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcS5KZARLZiKXM9PwwKZLGwdmf4cdSBnnQ1Hni4s6gERUlh7MDw7qFPenuFT37EE0CX7Uio9t0hSq0wHQrNd3gC7-oKcPcMWLfnpbpaZMef2KneaIOq7NrQtAbl7bGT1wHQdlA&usqp=CAc", store: jumbo },
    { name: "Vomar Speciale Olijfolie", image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcS5KZARLZiKXM9PwwKZLGwdmf4cdSBnnQ1Hni4s6gERUlh7MDw7qFPenuFT37EE0CX7Uio9t0hSq0wHQrNd3gC7-oKcPcMWLfnpbpaZMef2KneaIOq7NrQtAbl7bGT1wHQdlA&usqp=CAc", store: vomar },
    { name: "Lidl Speciale Olijfolie", image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcS5KZARLZiKXM9PwwKZLGwdmf4cdSBnnQ1Hni4s6gERUlh7MDw7qFPenuFT37EE0CX7Uio9t0hSq0wHQrNd3gC7-oKcPcMWLfnpbpaZMef2KneaIOq7NrQtAbl7bGT1wHQdlA&usqp=CAc", store: lidl },
    { name: "AH Gourmet Kruidenset", image_url: "https://img.discountoffice.cloud/ZV-1FCRHSFrGvsGJpGxbcfWK4LzhMU35RzgbZll45HU/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1ExNDI5NzY3LTEuanBn.webp", store: ah },
    { name: "Jumbo Gourmet Kruidenset", image_url: "https://img.discountoffice.cloud/ZV-1FCRHSFrGvsGJpGxbcfWK4LzhMU35RzgbZll45HU/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1ExNDI5NzY3LTEuanBn.webp", store: jumbo },
    { name: "Vomar Gourmet Kruidenset", image_url: "https://img.discountoffice.cloud/ZV-1FCRHSFrGvsGJpGxbcfWK4LzhMU35RzgbZll45HU/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1ExNDI5NzY3LTEuanBn.webp", store: vomar },
    { name: "Lidl Gourmet Kruidenset", image_url: "https://img.discountoffice.cloud/ZV-1FCRHSFrGvsGJpGxbcfWK4LzhMU35RzgbZll45HU/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1ExNDI5NzY3LTEuanBn.webp", store: lidl }
  ]
}

# Create products and deals
product_definitions.each do |category, items|
  items.each do |item|
    product = Product.create!(
      name: item[:name],
      category: category,
      image_url: item[:image_url]
    )
    products << product
    puts "Created product: #{product.name} in category: #{product.category}"

    # Pricing logic based on category
deal_type = deal_types.sample
case category
when "Fruits & Vegetables", "Dairy & Eggs", "Bakery", "Beverages", "Snacks & Sweets", "Cheese", "Pasta, Rice & International", "Canned Goods & Condiments", "Breakfast & Spreads", "Coffee & Tea", "Drugstore"
  case deal_type
  when "1+1 gratis", "2+2 gratis"
    price = rand(1.5..5.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(1.5..5.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(1.5..5.0).round(2)
    discounted_price = (price * 0.8).round(2)
  when "40% korting"
    price = rand(1.5..5.0).round(2)
    discounted_price = (price * 0.6).round(2)
  else
    price = rand(1.5..5.0).round(2)
    discounted_price = (price - rand(0.5..1.5)).round(2)
  end
when "Meat & Fish", "Ready Meals", "Frozen Foods"
  case deal_type
  when "1+1 gratis", "2+2 gratis"
    price = rand(5.0..8.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.8).round(2)
  when "40% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.6).round(2)
  else
    price = rand(5.0..15.0).round(2)
    discounted_price = (price - rand(1.0..3.0)).round(2)
  end
when "Alcohol"
  case deal_type
  when "1+1 gratis", "2+2 gratis"
    price = rand(5.0..10.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(5.0..20.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(5.0..20.0).round(2)
    discounted_price = (price * 0.8).round(2)
  when "40% korting"
    price = rand(5.0..20.0).round(2)
    discounted_price = (price * 0.6).round(2)
  else
    price = rand(5.0..20.0).round(2)
    discounted_price = (price - rand(1.0..5.0)).round(2)
  end
when "Household", "Baby Products", "Non-Food", "Seasonal"
  case deal_type
  when "1+1 gratis", "2+2 gratis"
    price = rand(2.0..8.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(2.0..10.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(2.0..10.0).round(2)
    discounted_price = (price * 0.8).round(2)
  when "40% korting"
    price = rand(2.0..10.0).round(2)
    discounted_price = (price * 0.6).round(2)
  else
    price = rand(2.0..10.0).round(2)
    discounted_price = (price - rand(0.5..2.0)).round(2)
  end
when "Online Only"
  case deal_type
  when "1+1 gratis", "2+2 gratis"
    price = rand(5.0..10.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.8).round(2)
  when "40% korting"
    price = rand(5.0..15.0).round(2)
    discounted_price = (price * 0.6).round(2)
  else
    price = rand(5.0..15.0).round(2)
    discounted_price = (price - rand(1.0..3.0)).round(2)
  end
end

    deal = Deal.create!(
      price: price,
      discounted_price: discounted_price,
      expiry_date: Faker::Date.forward(days: 30),
      product: product,
      store: item[:store],
      deal_type: deal_type
    )
    deals << deal
    puts "Created deal for #{product.name} with deal_type: #{deal.deal_type}, price: #{deal.price}€, discounted: #{deal.discounted_price}€"
  end
end
puts "✅ Created #{products.count} products and #{deals.count} deals"

puts "Seeding completed successfully! 🎉"
