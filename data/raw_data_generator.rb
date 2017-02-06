require 'Faker'

class Raw_data_generator
  def initialize(locale, name_size, address_size, phone_size)
    case locale
    when 'en-US'
      @method = self.method(:generate_us)
    when 'ru-RU'
      @method = self.method(:generate_ru)
    when 'en-GB'
      @method = self.method(:generate_uk)
    when 'by-BY'
      @method = self.method(:generate_by)
    else
      STDERR.puts "Cannot recognise #{locale} as locale"
      exit
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
    File.open './data/en_US/names_us.txt', 'w' do |f|
      @name_size.times { f.puts Faker::Name.unique.name }
    end
    File.open './data/en_US/addresses_us.txt', 'w' do |f|
      @address_size.times do
        full_address = Faker::Address.unique.full_address.match(/[\w\s]*,[\w\s]*, \w\w/).to_s.strip
        zip_code = Faker::Address.zip_code(full_address.match(/\w*\b$/).to_s)
        f.puts "#{full_address}, USA, #{zip_code}"
      end
    end
    File.open './data/en_US/phones_us.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number }
    end
  end

  def generate_ru
    Faker::Config.locale = 'ru'
    File.open './data/ru_RU/names_ru.txt', 'w' do |f|
      @name_size.times { f.puts Faker::Name.unique.name }
    end
    File.open './data/ru_RU/addresses_ru.txt', 'w' do |f|
      @address_size.times { f.puts "#{Faker::Address.unique.street_address(true)}, #{Faker::Address.city}, #{Faker::Address.default_country}, #{Faker::Address.postcode}" }
    end
    File.open './data/ru_RU/phones_ru.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number }
    end
  end

  def generate_uk
    Faker::Config.locale = 'en-GB'
    File.open './data/en_GB/names_gb.txt', 'w' do |f|
      @name_size.times { f.puts Faker::Name.unique.name }
    end
    File.open './data/en_GB/addresses_gb.txt', 'w' do |f|
      @address_size.times do
        full_address = Faker::Address.unique.full_address.match(/[\w\s]*,[\w\s]*, \w\w/).to_s.strip
        f.puts "#{full_address}, UK, #{Faker::Address.zip_code}"
      end
    end
    File.open './data/en_GB/phones_gb.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number.to_s.gsub!(/\s+/, '-') }
    end
  end

  def generate_by
    Faker::Config.locale = 'by'
    File.open './data/by_BY/names_by.txt', 'w' do |f|
      m_names, f_names, m_surnames, f_surnames = [], [], [], []
      File.open './data/by_BY/helpers/by_name_m.txt', 'r' do |f_name|
        m_names = f_name.readline.to_s.force_encoding('Windows-1251').split
      end
      File.open './data/by_BY/helpers/by_name_f.txt', 'r' do |f_name|
        f_names = f_name.readline.to_s.force_encoding('Windows-1251').split
      end
      File.open './data/by_BY/helpers/by_surname_m.txt', 'r' do |f_name|
        m_surnames = f_name.readline.to_s.force_encoding('Windows-1251').split
      end
      File.open './data/by_BY/helpers/by_surname_f.txt', 'r' do |f_name|
        f_surnames = f_name.readline.to_s.force_encoding('Windows-1251').split
      end
      used = {}
      @name_size.times do
        if rand(2) == 0
          while used.has_key? ((name = "#{m_names[rand(m_names.length)]} #{m_surnames[rand(m_surnames.length)]}").hash)
          end
        else
          while used.has_key? ((name = "#{f_names[rand(f_names.length)]} #{f_surnames[rand(f_surnames.length)]}").hash)
          end
        end
        f.puts name
        used[name.hash] = true
      end
    end
    File.open './data/by_BY/addresses_by.txt', 'w' do |f|
      @address_size.times do
        full_address = Faker::Address.unique.full_address.to_s
        zip_code = full_address.match(/[0-9]{6}/).to_s
        full_address = full_address.gsub!(zip_code + ' ', '') + ", #{zip_code}"
        f.puts full_address.force_encoding('UTF-8')
      end
    end
    File.open './data/by_BY/phones_by.txt', 'w' do |f|
      @phone_size.times { f.puts Faker::PhoneNumber.unique.phone_number }
    end
  end
end

generator = Raw_data_generator.new('by-BY', 10000, 10000, 10000)
generator.generate
generator = Raw_data_generator.new('ru-RU', 10000, 10000, 10000)
generator.generate
generator = Raw_data_generator.new('en-US', 10000, 10000, 10000)
generator.generate
generator = Raw_data_generator.new('en-GB', 10000, 10000, 10000)
generator.generate