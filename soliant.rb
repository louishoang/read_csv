# require 'pry'
require 'csv'

class ContactManager
  attr_accessor :file, :alphabet_index, :index_by_email

  def initialize(file=nil, args={})
    @file = file
    @alphabet_index = args[:alphabet_index] || {}
    @index_by_email = args[:index_by_email] || {}
  end

  def load_file
    CSV.foreach(file, :headers => true) do |row|
      build_index_alphabetically(row)
      build_index_by_email(row)
    end
    sort_alphabet_index_by_last_name
    self.class.new(nil, {alphabet_index: alphabet_index,
      index_by_email: index_by_email})
  end

  def build_index_alphabetically(row)
    first_letter = row["last_name"][0].downcase
    alphabet_index[first_letter] = [] unless alphabet_index.has_key?(first_letter)
    record = {}
    columns.each{|col| record[col] = row[col].downcase}
    alphabet_index[first_letter] << record
  end

  def build_index_by_email(row)
    record = {}
    columns.delete("email")
    columns.each{|col| record[col] = row[col].downcase}
    email = row["email"].downcase
    if index_by_email.has_key?(email)
      handle_duplicate_email(email, record)
    else
      index_by_email[email] = record
    end
  end

  def handle_duplicate_email(email, record)
    puts "Email #{email} is existed, please choose action:"
    puts "1 - Keep old record"
    puts "2 - Use new record"
    input = gets.chomp
    input == "1" ? return : index_by_email[email] = record
  end

  def sort_alphabet_index_by_last_name
    alphabet_index.each do |k, v|
      alphabet_index[k] = v.sort_by{|x| x["last_name"]}
    end
  end

  def search_by_last_name_first_letter(letter)
    alphabet_index.has_key?(letter) ? format_n_print(alphabet_index[letter]) : no_record
  end

  def search_by_email(email)
    index_by_email.has_key?(email) ? format_n_print(index_by_email[email]) : no_record
  end

  def format_n_print(results)
    results = [results] unless results.is_a?(Array)
    puts "Found #{results.size} records:"
    results.each do |record|
      puts "Last: #{record['last_name'].capitalize}, First: #{record['first_name'].capitalize}, Phone: #{record['phone']}, E-mail: #{record['email']}"
    end
  end

  def no_record
    puts "There is (0) record found"
  end

  def columns
    ["email", "last_name", "first_name", "phone"]
  end

  def prompt_for_action
    2.times{puts ""}
    puts "===>  Please choose action number:"
    puts "1 - Search By Email"
    puts "2 - Search By Letter"
    puts "3 - Exit"
    input = gets.chomp
    if input == "1"
      puts "===>  Please provide an email"
      input = gets.chomp.downcase
      search_by_email(input) if input
    elsif input == "2"
      puts "===> Please provide a letter"
      input = gets.chomp.downcase
      search_by_last_name_first_letter(input) if input
    elsif input == "3"
      throw(:done)
    else
      puts "===> Please type 1, 2 or 3 only"
    end
  end

  def run
    catch(:done) do
      loop do
        prompt_for_action
      end
    end
  end
end

client = ContactManager.new("contacts.csv").load_file.run

