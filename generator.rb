require 'Faker'

class Generator

  REGIONS = %w(en_GB en_US ru_RU by_BY)

  def self.generate
    check_arguments

    names, adresses, phones = [], [], []
    names = File.open("./data/#{ARGV[0]}/names_#{ARGV[0][-2..-1].to_s.downcase}.txt", 'r:windows-1251:utf-8').readlines
    adresses = File.open("./data/#{ARGV[0]}/addresses_#{ARGV[0][-2..-1].to_s.downcase}.txt").readlines
    phones = File.open("./data/#{ARGV[0]}/phones_#{ARGV[0][-2..-1].to_s.downcase}.txt").readlines

    used = Hash.new(false)
    Integer(ARGV[1]).times do
      while used.has_key? ((record = "#{names[rand(names.length)]}; #{adresses[rand(adresses.length)]}; #{phones[rand(phones.length)]}".gsub "\n", '').hash)
      end
      used[record.hash] = true

      current_error_residual = Float(ARGV[2])
      Integer(current_error_residual).times do
        case rand 3
        when 0
          if ARGV[0].to_s.include? 'en'
            record.insert(rand(record.length), ('a'..'z').to_a[rand(26)])
          elsif (ARGV[0].to_s.include? 'ru') || (ARGV[0].to_s.include? 'by')
            record.insert(rand(record.length), names[rand(names.length)][0])
          end
        when 1
          record.slice!(rand(record.length))
        when 2
          i = rand(record.length - 1)
          record[i], record[i + 1] = record[i + 1], record[i]
        end
      end
      puts record
      current_error_residual -= Integer(current_error_residual) - Float(ARGV[2])
    end
  end

  private
  def self.check_arguments
    if ARGV.length != 3
      STDERR.puts "Invalid amount of arguments ! 3 expected, but #{ARGV.length} found."
      exit
    end


    unless REGIONS.any? { |region| region == ARGV[0] }
      STDERR.puts "Cannot recognise specified region. Any of #{REGIONS} expected, but #{ARGV[0]} found."
      exit
    end

    unless ARGV[1] =~ /\A[0-9]+\z/
      STDERR.puts "The second argument is expected to be non-negative integer, but #{ARGV[1]} found."
      exit
    end

    unless ARGV[2] =~ /\A[0-9]+.?[0-9]*\z/
      STDERR.puts "The third argument is expected to be non-negative float, but #{ARGV[2]} found."
      exit
    end
  end

end

#start = Time.now
Generator.generate
#puts Time.now - start