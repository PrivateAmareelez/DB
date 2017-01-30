require 'Faker'

class Generator

  REGIONS = ['UK', 'US', 'RU', 'BY']

  def self.generate
    check_arguments
    generateUS(Integer(ARGV[1]), Float(ARGV[2]))
  end

  private
  def self.check_arguments
    if ARGV.length != 3
      puts "Invalid amount of arguments ! 3 expected, but #{ARGV.length} found."
      exit
    end


    unless REGIONS.any? { |region| region == ARGV[0] }
      puts "Cannot recognise specified region. Any of #{REGIONS} expected, but #{ARGV[0]} found."
      exit
    end

    unless ARGV[1] =~ /\A[0-9]+\z/
      puts "The second argument is expected to be non-negative integer, but #{ARGV[1]} found."
      exit
    end

    unless ARGV[2] =~ /\A[0-9]+.?[0-9]*\z/
      puts "The third argument is expected to be non-negative float, but #{ARGV[2]} found."
      exit
    end
  end

  def self.generateUS size, error_value
    Faker::Config.locale    = 'en-US'
    names, adresses, phones = [], [], []
    sample_size             = Integer((2 * Math.cbrt(size)))
    sample_size.times do
      names.push Faker::Name.unique.name
      adresses.push Faker::Address.unique.full_address
      phones.push "+(#{Faker::PhoneNumber.area_code})#{Faker::PhoneNumber.exchange_code}-#{Faker::PhoneNumber.subscriber_number(4)}"
    end

    current_error_residual = error_value;
    used = Hash.new(0)
    size.times do
      String record = "#{names[rand(sample_size)]}; #{adresses[rand(sample_size)]}, USA; #{phones[rand(sample_size)]}"
      while used.has_key? record.hash
        record = "#{names[rand(sample_size)]}; #{adresses[rand(sample_size)]}, USA; #{phones[rand(sample_size)]}"
      end
      Integer(current_error_residual).times do
        case rand 3
        when 1
          record.insert(rand(record.length), ('a'..'z').to_a[rand(26)])
        when 2
          record.slice!(rand(record.length))
        when 3
          i, temp = rand(record.length - 1), record[i].dup
          record[i], record[i + 1] = record[i + 1], temp
        end
      end
      puts record
      current_error_residual -= Integer(current_error_residual) - error_value;
    end
  end
end

start = Time.now
Generator.generate
puts Time.now - start
###