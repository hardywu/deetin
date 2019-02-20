# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create \
  email: 'john@barong.io',
  password: '123456',
  domain: 'nanyazq.com',
  role: 'member',
  state: 'active',
  level: 2

# Market.destroy_all
# FuturesMarket.destroy_all

FuturesMarket.create \
  code: 'CMGCA0',
  base_unit: 'GC',
  quote_unit: 'USD',
  name: ''
