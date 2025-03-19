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
# Seed Stores with real addresses
puts "Seeding Stores with logos..."
stores_data = [
  { name: "Albert Heijn", location: "Provincialeweg 11, 1506 MA Zaandam, Netherlands", website_url: "https://www.ah.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Albert_Heijn_Logo.svg/1956px-Albert_Heijn_Logo.svg.png" },
  { name: "Jumbo", location: "Rijksweg 15, 5462 CE Veghel, Netherlands", website_url: "https://www.jumbo.com", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Jumbo_Logo.svg/1000px-Jumbo_Logo.svg.png" },
  { name: "Vomar", location: "Kaaikhof 13, 1567 JP Assendelft, Netherlands", website_url: "https://www.vomar.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Vomar-logo.jpg/800px-Vomar-logo.jpg" },
  { name: "Lidl", location: "Hullenbergweg 2, 1101 BL Amsterdam, Netherlands", website_url: "https://www.lidl.nl", logo_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Lidl-Logo.svg/640px-Lidl-Logo.svg.png" }
]

stores = stores_data.map { |store| Store.create!(store) }
puts "✅ Created #{stores.count} stores"

user1 = User.create!(
  name: Faker::Name.name,
  email: "user1@example.com",
  password: "password123"
)
puts "✅ Created 1 user"

categories = [
  "Fruits & Vegetables", "Ready Meals", "Meat & Fish", "Cheese", "Dairy & Eggs", "Bakery",
  "Snacks & Sweets", "Pasta, Rice & International", "Canned Goods & Condiments",
  "Breakfast & Spreads", "Frozen Foods", "Coffee & Tea", "Beverages", "Alcohol",
  "Drugstore", "Household", "Baby Products", "Non-Food", "Seasonal", "Online Only"
]

products = []
puts "Seeding Products..."

vomar, lidl = stores.select { |store| ["Vomar", "Lidl"].include?(store.name) }

product_definitions = {
  "Fruits & Vegetables" => [
    { name: "Verse Appels", image_url: "https://images.unsplash.com/photo-1623815242959-fb20354f9b8d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" },
    { name: "Broccoli", image_url: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?q=80&w=1801&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" },
    { name: "Wortelen", image_url: "https://ictagrisindh.gov.pk/assets/uploads/crops/a2237670547780096024583f333bcefd.jpeg" }
  ],
  "Ready Meals" => [
    { name: "Kip Curry", image_url: "https://digitalcontent.api.tesco.com/v2/media/ghs/0fd054c5-5ef9-4f50-9d3e-9b73de7eb276/fd8657b2-eb3b-4c6a-b071-1d8f83790e5c.jpeg?h=960&w=960" },
    { name: "Groente Lasagne", image_url: "https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQYsSUsi1PpwOiTtr5jRCjnXqhJTF9CimtXYQZgEW--XRyqgkXLswb5RTEI_zb-HAqc5zYWRdndDvBKbL_N5ciAaChya2s28TmpTJPLvKrKqZb45F4&usqp=CAc" }
  ],
  "Meat & Fish" => [
    { name: "Kipfilet", image_url: "https://plus.unsplash.com/premium_photo-1723579413852-d71dbd8641d2?q=80&w=2036&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" },
    { name: "Zalmfilet", image_url: "https://images.unsplash.com/photo-1499125562588-29fb8a56b5d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" },
    { name: "Rundergehakt", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vomar-Rundergehakt-ca.-300-g-2234130000000-1-637957244301753542.png" }
  ],
  "Cheese" => [
    { name: "Goudse Kaas", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Jong-Gouda-Kaas-48-200-g-8710866043548-1-637957248734609972.png" },
    { name: "Cheddar Blok", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vergeer-Holland-Geraspt-Cheddar-50-150-g-8710866032351-1-637957267211829625.png" }
  ],
  "Dairy & Eggs" => [
    { name: "Volle Melk", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/-Zuivelmeester-Halfvolle-Melk-2-L-8710624326364-1-637957265105713936.png" },
    { name: "Scharreleieren", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Scharreleieren-Klasse-A-10-Stuks-8710624346232-1-637641864854972461.png" },
    { name: "Griekse Yoghurt", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/MELKAN-GRIEKSE-YOG-10-150GR-8718989042158-0-638609776877368076.png" }
  ],
  "Bakery" => [
    { name: "Wit Brood", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/RD-VOMAR-ROND-WIT-HEEL-2250840000000-0-638276891632919723.jpg" },
    { name: "Croissants", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Roomboter-Croissants-4-x-45-g-8710624214463-1-637957255154361173.png" },
    { name: "Baguette", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Vomar-Baguette-2255210000000-1-637957239339516609.png" }
  ],
  "Pantry" => [
    { name: "Pasta", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Grand-Italia-Mini-Penne-Tradizionali-350-g-8000050138809-1-638435016321100547.png" }, # "Pasta" often stays the same
    { name: "Rijst", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Saitaku-Sushi-Rice-500-g-5060194790069-1-637431034207759764.png" },
    { name: "Tomatensaus", image_url: "https://imgproxy-retcat.assets.schwarz/XVXsQI-eObYdCYqYrVFM1F4L7PppeEMK6gAGEv7AM5o/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BODE1MTY4Mzk4NkRDQjNDOTVEQ0E2OEM/1MzYwQTEwRjVDQkRDRjk5OUE5QTcwMUUwREZDNDFDOTVGQjNBQTcwLmpwZw.jpg" }
  ],
  "Beverages" => [
    { name: "Sinaasappelsap", image_url: "https://imgproxy-retcat.assets.schwarz/VY6NZPqZg4C8j-dTdnh_-yoyL_UblGx8FB3P1wEzIMI/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9CMUM0RjM1QjhCODEwQ0ZERDE3NEU2RTI/4RUU4MUY5OEFGOEVDNzFCRTBGN0VCRTFDN0I0MDU1ODIzNDg2MjY3LmpwZw.jpg" },
    { name: "Fleswater", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/SPA-REINE-Natuurlijk-Mineraalwater-1l-5410013136149-1-638440417218782936.png" },
    { name: "Koffiebonen", image_url: "https://imgproxy-retcat.assets.schwarz/C99iMrJXU-gts9_9B28eUyTWzj6snwa3XU2zHgtEDH4/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0Q4NThGRkFCQ0YwRUQxNDUxREI2QTc3Nj/E3NTM2NzZFQ0ZFQkZCRDRBMDEyRjZCMzlEQkEzN0Q1N0U3MEMxM0EucG5n.png" }
  ],
  "Snacks" => [
    { name: "Aardappelchips", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/g-woon-Naturel-Tortilla-Chips-165-g-8710624266455-1-637957254507948590.png" },
    { name: "Chocoladereep", image_url: "https://www.compliment.nl/wp-content/uploads/2020/05/Toffifee-15x-125gr-3_jpg.webp" },
    { name: "Gemengde Noten", image_url: "https://imgproxy-retcat.assets.schwarz/bGLE90pseaBNalZ_G2tD1KpiaSmV8ZxniugY4Um3ZHA/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0I5N0NBQTJDNkI3Q0YwODY4Q0MzNzI0M0/JBM0M1NkNENUU1MENEQTQyNkE0NDAzMTZEQjNENjYwQjlEQkRCNDAucG5n.png" }
  ],
  "Frozen Foods" => [
    { name: "Diepvriespizza", image_url: "https://images.migrosone.com/sanalmarket/product/17555667/17555667-c03827-1650x1650.jpg" },
    { name: "Roomijs", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Ben-Jerry-s-IJs-Cookie-Dough-100-ml-8711200564149-1-638217504147197387.png" },
    { name: "Diepvriesgroenten", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/810258.png" }
  ],
  "Household Supplies" => [
    { name: "Toiletpapier", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-WOON-TOILETPAPIER-4-LGS-6R-8718989029142-0-638610381135771332.png" },
    { name: "Afwaszeep", image_url: "https://imgproxy-retcat.assets.schwarz/mXmROcuLmWSoSyNXwAuJ--3HbwQO7mNrdBTX9aUs8BU/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82Q0QyNTJDODkxMDNDNkRGMzFEODdGNjk/1QUQxODE5RkY0OUMzMTYwM0Q3NjYzNTAzMTMxMUNGMDg4NEUxQThFLmpwZw.jpg" },
    { name: "Wasmiddel", image_url: "https://imgproxy-retcat.assets.schwarz/RNo5u6CYlF-H1Ebs7AADs4hhdG4D1te4Cs1VrCUxjS4/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS8zOUU2NUQ3MjUzQzlFNThCNjNERkI4QzQ/3QUREOUM1M0ZDNjEyMTM5QUUwM0MwOEQ2RjA0NzhEQTkzRTAwQkEwLmpwZw.jpg" }
  ],
  "Personal Care" => [
    { name: "Shampoo", image_url: "https://imgproxy-retcat.assets.schwarz/LElwUqKR-pOvZnJrJ0nD64Em-qRIpnLt8pasAXYJNe8/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9EMDkwNzc0NTMwODkxNERENjJEQzUyNTd/GQTdCRTk3MTVEN0RFQjMyM0E1NTlGNUI0RTVBRjQ3RjRCREZDQURELmpwZw.jpg" },
    { name: "Tandpasta", image_url: "https://imgproxy-retcat.assets.schwarz/RIUeMtOhxqvvAq5JSMgLAo8Hp4ZXIQNlZRHCN9XrZPA/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9GOEQwNkIwMzA0RTg2NEY2NjYyMTc2Q0U/4MEUwRUQzNERFQTQzQTQ5Q0U4MDA2RjEyRUE5NjJFMjMxMTY2MEU0LmpwZw.jpg" },
    { name: "Handzeep", image_url: "https://imgproxy-retcat.assets.schwarz/wUIvshj0vYj1S_xubIWTU8H-QXidotcL8euXBfJxwTw/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0E0MzlERDUwMUFBMTZDNjBDRkQ4QzE0OD/NDQjdBMEExQkJBQzYzQTRGMUU4QzY2MDRCRkJFMUZENTRCMkQyQzAucG5n.png" }
  ],
  "Baby Products" => [
    { name: "Luiers", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonb-b-Ultra-Zachte-Luiers-Maxi-4-8-16-kg-40-Stuks-8710624280314-1-637957252959183165.png" },
    { name: "Babydoekjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Huggies-Baby-Cleansing-Wipes-Pure-56-Stuks-5029053550039-1-637957269810293118.png" },
    { name: "Zuigelingenvoeding", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Bonbebe-Fruit-met-Koek-200-g-8710624288938-1-637957255488114725.png" }
  ],
  "Pet Supplies" => [
    { name: "Hondenvoer", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-hond-kluiven-500gr-8718989025618-0-638612288660403580.png" },
    { name: "Kattenbakvulling", image_url: "https://imgproxy-retcat.assets.schwarz/2tYAmVZOiSeRigNj6lVdnWJmcTqr8nK6NfntS0uaEpo/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS81NjkzQ0MyRTJEMjNGNkIzMDEwRDAxMzE/wMEExMDVEQzFBMkVDRjgzOTg3OEZFNEZDNUE2NzBDMkIzMUMyMDZFLmpwZw.jpg" },
    { name: "Huisdierenshampoo", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Garnier-Loving-Blends-Shampoo-Honing-Goud-300-ml-3600542462259-1-638007339813163427.png" }
  ],
  "Pasta, Rice & International" => [
    { name: "Spaghetti", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Casa-Italiana-Spaghetti-1000-g-8710624178628-1-637957238105285747.png" },
    { name: "Jasmijnrijst", image_url: "https://imgproxy-retcat.assets.schwarz/575BPgXBxriTYYx26fzzhoE3LQJdxU_wIEEydDAf43g/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9ENkIwRDg3MzI2N0E2RTJENDFFRUNDMUQ/4NDA1NjQ2QTNFOTlCQUIzNDlCM0JCMEE0NjU5QkM3NkFDMENBQ0Q1LmpwZw.jpg" }
  ],
  "Canned Goods & Condiments" => [
    { name: "Tonijn in Blik", image_url: "https://imgproxy-retcat.assets.schwarz/S6P3JYgmVmRrIhcDmwjr_sxx8IBvBmkoK2z_PuX2HnY/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50Lzc5M0JEOUU3MTAyQUVFNzE2QzUyQzc4Qz/EyNDY5MEM5MTdDMUM5OTkyRjU0RDIwOTc2MjExMDRFMDQwNkI1NUQucG5n.png" },
    { name: "Ketchup", image_url: "https://imgproxy-retcat.assets.schwarz/YKaWrqb6UZl3iDhBdu5w_RPzwY_vRUcaCnJsAQp95LE/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS9BQThCN0VFNTE5NTcyOTZDMTRFQkQzNUJ/EMzA5NDVEMDg3NUY0QTMzRENEOUE5MjFCMTE4QkZFM0JCOUIzQkU2LmpwZw.jpg" } # "Ketchup" is the same in Dutch
  ],
  "Breakfast & Spreads" => [
    { name: "Cornflakes", image_url: "https://imgproxy-retcat.assets.schwarz/Lm0A_743B3Bg5vzTaKPoAItc49WtdTYmSQ7xLg8Kt-w/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS83MjAyNzdCNUNDOTJCNjYzREU5N0FBOUN/FMjhENDAwMUZBQTI0N0Q4NkJFOEIwMjlFQTU3REQwRkMzMTFCQUEwLmpwZw.jpg" }, # "Cornflakes" is the same
    { name: "Pindakaas", image_url: "https://imgproxy-retcat.assets.schwarz/Nu7d2AtgQYrVtHhj_8PyDXk5xQ5P0yXbM4gVFJGRVsw/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvaW50L0FDRDgwNzI3MDAzMjdGMDU5NTE5Nzg0N0/JFNTAxQkFCOTE2RkYyRjA5RjYxRkJCRDUwRUFDMjU4NUZGMkZERTMucG5n.png" }
  ],
  "Coffee & Tea" => [
    { name: "Gemalen Koffie", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Douwe-Egberts-Aroma-Rood-Filterkoffie-250-g-8711000003145-1-637957263472727579.png" },
    { name: "Groene Theezakjes", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/G-woon-Groene-Thee-Citroen-20-x-1-5-g-8710624324261-1-637957261429111159.png" }
  ],
  "Alcohol" => [
    { name: "Rode Wijn", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Just-0-Red-Wine-Alcoholfree-0-75-L-4003301069048-1-637957247344440393.png" },
    { name: "Lager Bier", image_url: "https://imgproxy-retcat.assets.schwarz/Wj4LTSJXn75DmU-7_S3SFjkQY2iLeEbTRrEjMuIp-og/sm:1/w:1278/h:959/cz/M6Ly9wcm9kLWNhd/GFsb2ctbWVkaWEvbmwvMS82QzYwQkE0MjcxNUFEODNFMzM1MURCNDE/5OUZGODdCNTZGNDA4MUIxNDBEMDJDNDFGOEZENzc4NjdDNzNFNzM3LmpwZw.jpg" }
  ],
  "Drugstore" => [
    { name: "Pijnstillers", image_url: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" },
    { name: "Pleisters", image_url: "https://img.fruugo.com/product/8/49/924529498_max.jpg" }
  ],
  "Household" => [
    { name: "Keukenpapier", image_url: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSAXIJJPV4q8awSE_El-m9tM9wSlkjyNq7DjWa6ued1l2YQLExEkqarCuO6wazw853PQ6iVRamlRoWn_FRbo1DGWNGNTc5s6qQQ3kvLI-2XMYZ4FZyunZnJ" },
    { name: "Vuilniszakken", image_url: "https://takeaware.nl/cdn/shop/files/9925020-komo-huisvuilzakken-met-sluitstrip-60x80cm-grijs-1129163810.png?v=1739239902&width=1200" }
  ],
  "Non-Food" => [
    { name: "Batterijen", image_url: "https://d3vricquk1sjgf.cloudfront.net/articles/Varta-Longlife-Power-Alkaline-9V-4008496559862-1-638044488453107957.png" },
    { name: "Lampen", image_url: "https://m.media-amazon.com/images/I/71eCn2-T1hL.__AC_SX300_SY300_QL70_ML2_.jpg" }
  ],
  "Seasonal" => [
    { name: "Paaschocolade-eieren", image_url: "https://img.discountoffice.cloud/W1qNtI-529uvUF3m2MckDEhr8JGjv6fF_xEO0S0ldz0/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1E5NjA4NzMtMS5qcGc.webp" },
    { name: "Halloween Snoep", image_url: "https://cdn.sneltoner.nl/Additional/300x300/uploaded_66ac1f41-59fa-493b-9bdb-0cad9ec4f57c_cel58132.jpg" }
  ],
  "Online Only" => [
    { name: "Speciale Olijfolie", image_url: "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcS5KZARLZiKXM9PwwKZLGwdmf4cdSBnnQ1Hni4s6gERUlh7MDw7qFPenuFT37EE0CX7Uio9t0hSq0wHQrNd3gC7-oKcPcMWLfnpbpaZMef2KneaIOq7NrQtAbl7bGT1wHQdlA&usqp=CAc" },
    { name: "Gourmet Kruidenset", image_url: "https://img.discountoffice.cloud/ZV-1FCRHSFrGvsGJpGxbcfWK4LzhMU35RzgbZll45HU/bg:ffffff/rs:fit:640:480:1:1/g:ce/bG9jYWw6Ly8vZGlzY291bnQtd2Vic2l0ZS9wcm9kdWN0SW1hZ2VzLzgvb3JnL1ExNDI5NzY3LTEuanBn.webp" }
  ]
}

product_definitions.each do |category, items|
  items.each do |item|
    product = Product.create!(
      name: item[:name],
      category: category,
      image_url: item[:image_url]
    )
    products << product
    puts "Created product: #{product.name} in category: #{product.category}"
  end
end

product_definitions.each do |category, items|
  items.each do |item|
    product = Product.create!(
      name: item[:name],
      category: category,
      image_url: item[:image_url]
    )
    products << product
    puts "Created product: #{product.name} in category: #{product.category}"
  end
end
puts "✅ Created #{products.count} products"

deals = []
puts "Seeding Deals..."

deal_types = [
  "1 voor 9.99",
  "1+1 gratis",
  "30% korting",
  "2+2 gratis",
  "20% korting"
]

products.each_with_index do |product, index|
  store = index < products.size / 2 ? vomar : lidl
  deal_type = deal_types.sample

  case deal_type
  when "1 voor 9.99"
    price = rand(11.0..14.0).round(2)
    discounted_price = 9.99
  when "1+1 gratis", "2+2 gratis"
    price = rand(3.0..8.0).round(2)
    discounted_price = (price / 2.0).round(2)
  when "30% korting"
    price = rand(3.0..12.0).round(2)
    discounted_price = (price * 0.7).round(2)
  when "20% korting"
    price = rand(3.0..12.0).round(2)
    discounted_price = (price * 0.8).round(2)
  else
    price = rand(3.0..12.0).round(2)
    discounted_price = (price - rand(0.5..2.0)).round(2)
  end

  deal = Deal.create!(
    price: price,
    discounted_price: discounted_price,
    expiry_date: Faker::Date.forward(days: 30),
    product: product,
    store: store,
    deal_type: deal_type
  )
  deals << deal
  puts "Created deal for #{product.name} with deal_type: #{deal.deal_type}, price: #{deal.price}€, discounted: #{deal.discounted_price}€"
end
puts "✅ Created #{deals.count} deals"

puts "Seeding completed successfully! 🎉"
