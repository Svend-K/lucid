# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# 50.times do
#   City.create({
#     name: Faker::Address.city,
#   })

#   Index.create({
#     name: Faker::Company.name,
#     score: rand(1..10)
#   })
# end

# 50.times do
#   CitiesIndex.create({
#     index_id: (1..50).to_a.sample,
#     city_id: (1..50).to_a.sample
#   })
# end

attr = {
       profile: [{name: 'worker'},
                 {name: 'student'},
                 {name: 'family'}],
       factor: [{name: 'burocracy'},
                {name: 'friendly to foreigners'},
                {name: 'fun'},
                {name: 'nightlife'},
                {name: 'english speaking'},
                {name: 'walkability'},
                {name: 'free wi-fi accessibility'},
                {name: 'public transport'},
                {name: 'high speed internet availability'},
                {name: 'access to rent'},
                {name: 'quality of education'}]
       }

Profile.create!(attr[:profile])
Factor.create!(attr[:factor])

