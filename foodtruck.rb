require 'net/http'
require 'uri'
require 'json'
require 'tmpdir'

# A tag that creates a href to the chicago food truck finder from a jekyll blog
# For example,
#
# {% foodtruck 5411empanadas %} 
#

module Jekyll
  class FoodTruckTag < Liquid::Tag

    def initialize(tag_name, foodtruck, tokens)
      super
      @foodtruck_id = foodtruck.gsub(/\s+/, "");
      @datafile = Dir.tmpdir()+ "/foodtruck_data.txt"
    end

    def render(context)
      foodtruck_name = read_cached_data
      if foodtruck_name.nil?
        uri = URI.parse("http://www.chicagofoodtruckfinder.com/services/trucks/#{@foodtruck_id}")
        puts "Requesting #{uri.inspect}"
        response = Net::HTTP.get_response(uri)
        foodtruck = JSON.parse(response.body)
        foodtruck_name = foodtruck['name']      
        write_cached_data(foodtruck_name)
      end
      "<a href='http://www.chicagofoodtruckfinder.com/trucks/#{@foodtruck_id}'>#{foodtruck_name}</a>"
    end

    private

    def write_cached_data(name)
      File.open(@datafile, 'a') { |f| f.write("#{@foodtruck_id},#{name}\n")}
    end

    def read_cached_data
      return nil unless File.exists?(@datafile)
      File.open(@datafile).each_line do |line|
        key,value = line.split(',')
        return value.rstrip if key == @foodtruck_id
      end
      return nil
    end
  end
end

Liquid::Template.register_tag('foodtruck', Jekyll::FoodTruckTag)
