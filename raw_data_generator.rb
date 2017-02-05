require 'Faker'

class Raw_data_generator
  def initialize(locale, name_size, address_size, phone_size)
    case locale
    when 'en-US'
      @method = self.method(:generate_us)
    when 'ru-RU'
      @method = self.method(:generate_ru)
    end
    @name_size = name_size
    @address_size = address_size
    @phone_size = phone_size
  end

  def generate
    @method.call
  end

  private
  def generate_us
    Faker::Config.locale = 'en-US'
    File.open 'names_us.txt', 'w' do |f|
      @name_size.times { f.puts Faker::Name.unique.name }
    end
    File.open 'addresses_us.txt', 'w' do |f|
      @address_size.times do
        full_address = Faker::Address.unique.full_address.match(/[\w\s]*,[\w\s]*, \w\w/).to_s.strip
        zip_code = Faker::Address.zip_code(full_address.match(/\w*\b$/).to_s)
        f.puts "#{full_address}, USA, #{zip_code}"
      end
    end
    File.open 'phones_us.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number }
    end
  end

  def generate_ru
    Faker::Config.locale = 'ru'
    File.open 'names_ru.txt', 'w' do |f|
      @name_size.times { f.puts Faker::Name.unique.name }
    end
    File.open 'adresses_ru.txt', 'w' do |f|
      @address_size.times { f.puts "#{Faker::Address.unique.street_address(true)}, #{Faker::Address.city}, #{Faker::Address.default_country}, #{Faker::Address.postcode}" }
    end
    File.open 'phones_ru.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number }
    end
  end

  def generate_uk

  end
end

generator = Raw_data_generator.new('ru-RU', 100, 100, 100)
generator.generate