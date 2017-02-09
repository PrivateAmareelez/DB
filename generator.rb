require 'Faker'

class Generator

  def self.generate
    check_arguments

    names, addresses, phones = load_files

    Integer(ARGV[1]).times do
      record = fix_existence(addresses, names, phones)
      make_error(names, record)
      puts record
    end
  end

  def self.fix_existence(addresses, names, phones)
    @used ||= Hash.new(false)
    while @used.has_key? ((record = "#{names[rand(names.length)]}; #{addresses[rand(addresses.length)]}; #{phones[rand(phones.length)]}".gsub! "\n", '').hash)
    end
    @used[record.hash] = true
    record
  end

  def self.make_error(names, record)
    @current_error_residual = Float(ARGV[2])
    error_types = { 0 => method(:make_add_error), }
    Integer(@current_error_residual).times do
      case rand 3
      when 0
        make_add_error(names, record)
      when 1
        make_delete_error(record)
      when 2
        make_swap_error(record)
      end
    end
    @current_error_residual -= Integer(@current_error_residual) - Float(ARGV[2])
  end

  def self.make_swap_error(record)
    i = rand(record.length - 1)
    record[i], record[i + 1] = record[i + 1], record[i]
  end

  def self.make_delete_error(record)
    record.slice!(rand(record.length))
  end

  def self.make_add_error(names, record)
    if ARGV[0].to_s.include? 'en'
      record.insert(rand(record.length), ('a'..'z').to_a[rand(26)])
    elsif (ARGV[0].to_s.include? 'ru') || (ARGV[0].to_s.include? 'by')
      record.insert(rand(record.length), names[rand(names.length)][0])
    end
  end

  def self.check_arguments
    check_arguments_length
    check_region
    check_size
    check_error_value
  end

  def self.check_arguments_length
    if ARGV.length != 3
      STDERR.puts "Invalid amount of arguments ! 3 expected, but #{ARGV.length} found."
      exit
    end
  end

  def self.check_error_value
    unless ARGV[2] =~ /\A[0-9]+.?[0-9]*\z/
      STDERR.puts "The third argument is expected to be non-negative float, but #{ARGV[2]} found."
      exit
    end
  end

  def self.check_size
    unless ARGV[1] =~ /\A[0-9]+\z/
      STDERR.puts "The second argument is expected to be non-negative integer, but #{ARGV[1]} found."
      exit
    end
  end

  def self.check_region
    regions = %w(en_GB en_US ru_RU by_BY)
    unless regions.any? { |region| region == ARGV[0] }
      STDERR.puts "Cannot recognise specified region. Any of #{regions} expected, but #{ARGV[0]} found."
      exit
    end
  end

  def self.load_files
    names = File.open("./data/#{ARGV[0]}/names_#{ARGV[0][-2..-1].to_s.downcase}.txt", 'r:windows-1251:utf-8').readlines
    addresses = File.open("./data/#{ARGV[0]}/addresses_#{ARGV[0][-2..-1].to_s.downcase}.txt").readlines
    phones = File.open("./data/#{ARGV[0]}/phones_#{ARGV[0][-2..-1].to_s.downcase}.txt").readlines
    return names, addresses, phones
  end

end

#start = Time.now
Generator.generate
#puts Time.now - start