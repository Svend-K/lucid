# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Index.create!(name: 'purchasing_power_incl_rent_index')

50.times do
  City.create({
    name: Faker::Address.city,
  })

  Index.create({
    name: Faker::Company.name,
    score: rand(1..10)
  })
end

50.times do
  CitiesIndex.create({
    index_id: (1..50).to_a.sample,
    city_id: (1..50).to_a.sample
  })
