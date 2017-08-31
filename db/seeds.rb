# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

attr = {
       profile: [{name: 'student'},
                 {name: 'worker'},
                 {name: 'family'}],
       factor: [{name: 'burocracy'},#1
                {name: 'friendly to foreigners'},#2
                {name: 'fun'},#3
                {name: 'nightlife'},#4
                {name: 'english speaking'},#5
                {name: 'walkability'},#6
                {name: 'free wi-fi accessibility'},#7
                {name: 'public transport'},#8
                {name: 'high speed internet availability'},#9
                {name: 'access to rent'},#10
                {name: 'quality of education'}],#11
        profiles_factor: [{profile_id: 1, factor_id: 4},
                          {profile_id: 1, factor_id: 11},
                          {profile_id: 1, factor_id: 8},
                          {profile_id: 1, factor_id: 2},
                          {profile_id: 1, factor_id: 5},
                          {profile_id: 2, factor_id: 3},
                          {profile_id: 2, factor_id: 9},
                          {profile_id: 2, factor_id: 10},
                          {profile_id: 2, factor_id: 2},
                          {profile_id: 2, factor_id: 5},
                          {profile_id: 3, factor_id: 11},
                          {profile_id: 3, factor_id: 5},
                          {profile_id: 3, factor_id: 2},
                          {profile_id: 3, factor_id: 1},
                          {profile_id: 3, factor_id: 3}]
       }

Profile.create!(attr[:profile])
Factor.create!(attr[:factor])
ProfilesFactor.create!(attr[:profiles_factor])

