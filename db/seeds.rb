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
  role: 'master',
  state: 'active',
  level: 2

User.create \
  email: 'test@nu0.one',
  password: '123456',
  domain: 'nanyazq.com',
  role: 'member',
  state: 'active',
  level: 2

Coin.create id: 'GX',
            name: 'Gaming Xerion',
            symbol: 'G',
            deposit_fee: 0,
            enabled: true

Coin.create id: 'GC',
            name: 'Gaming Center',
            symbol: 'C',
            deposit_fee: 0,
            enabled: true

Market.create \
  code: 'GC/CNY',
  base_unit: 'GC',
  quote_unit: 'CNY',
  name: 'GC CNY market'

Market.create \
  code: 'GX/CNY',
  base_unit: 'GX',
  quote_unit: 'CNY',
  name: 'GX CNY market'

Config.new name: 'ALIPAY_API_URL', value: 'https://openapi.alipaydev.com/gateway.do'

