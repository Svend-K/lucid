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
                          {profile_id: 1, factor_id: 3},
                          {profile_id: 2, factor_id: 3},
                          {profile_id: 2, factor_id: 9},
                          {profile_id: 2, factor_id: 10},
                          {profile_id: 2, factor_id: 2},
                          {profile_id: 2, factor_id: 5},
                          {profile_id: 2, factor_id: 1},
                          {profile_id: 3, factor_id: 11},
                          {profile_id: 3, factor_id: 5},
                          {profile_id: 3, factor_id: 2},
                          {profile_id: 3, factor_id: 1},
                          {profile_id: 3, factor_id: 8},
                          {profile_id: 3, factor_id: 6}],
        city: [{name: "london"},
               {name: "barcelona"},
               {name: "berlin"}],
                        #burocracy
        cities_factor: [{city_id: 1, factor_id: 1, score: 0.80},#london
                        {city_id: 2, factor_id: 1, score: 0.55},#barcelona
                        {city_id: 3, factor_id: 1, score: 0.85},#berlin

                        #friendly to foreigners
                        {city_id: 1, factor_id: 2, score: 0.9},#london
                        {city_id: 2, factor_id: 2, score: 0.7},#barcelona
                        {city_id: 3, factor_id: 2, score: 0.9},#berlin

                        #fun
                        {city_id: 1, factor_id: 3, score: 0.9},#london
                        {city_id: 2, factor_id: 3, score: 0.85},#barcelona
                        {city_id: 3, factor_id: 3, score: 0.95},#berlin

                        #nightlife
                        {city_id: 1, factor_id: 4, score: 0.65},#london
                        {city_id: 2, factor_id: 4, score: 0.65},#barcelona
                        {city_id: 3, factor_id: 4, score: 0.8},#berlin

                        #english speaking
                        {city_id: 1, factor_id: 5, score: 1.0},#london
                        {city_id: 2, factor_id: 5, score: 0.5},#barcelona
                        {city_id: 3, factor_id: 5, score: 0.95},#berlin

                        #walkability
                        {city_id: 1, factor_id: 6, score: 0.4},#london
                        {city_id: 2, factor_id: 6, score: 0.5},#barcelona
                        {city_id: 3, factor_id: 6, score: 0.6},#berlin

                        #free wi-fi accessibility
                        {city_id: 1, factor_id: 7, score: 0.6},#london
                        {city_id: 2, factor_id: 7, score: 0.5},#barcelona
                        {city_id: 3, factor_id: 7, score: 0.8},#berlin

                        #public transport
                        {city_id: 1, factor_id: 8, score: 0.65},#london
                        {city_id: 2, factor_id: 8, score: 0.55},#barcelona
                        {city_id: 3, factor_id: 8, score: 0.95},#berlin

                        #high speed internet availability
                        {city_id: 1, factor_id: 9, score: 0.7},#london
                        {city_id: 2, factor_id: 9, score: 0.65},#barcelona
                        {city_id: 3, factor_id: 9, score: 0.8},#berlin

                        #access to rent
                        {city_id: 1, factor_id: 10, score: 0.2},#london
                        {city_id: 2, factor_id: 10, score: 0.5},#barcelona
                        {city_id: 3, factor_id: 10, score: 0.6},#berlin

                        #quality of education
                        {city_id: 1, factor_id: 11, score: 0.9},#london
                        {city_id: 2, factor_id: 11, score: 0.6},#barcelona
                        {city_id: 3, factor_id: 11, score: 0.9}#berlin
                      ]
       }

Profile.create!(attr[:profile])
Factor.create!(attr[:factor])
ProfilesFactor.create!(attr[:profiles_factor])
City.create!(attr[:city])
CitiesFactor.create!(attr[:cities_factor])
