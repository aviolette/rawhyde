require 'net/http'
require 'uri'
require 'json'

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
    end

    def render(context)
      uri = URI.parse("http://www.chicagofoodtruckfinder.com/services/trucks/#{@foodtruck_id}")
      response = Net::HTTP.get_response(uri)
      foodtruck = JSON.parse(response.body)
      "<a href='http://www.chicagofoodtruckfinder.com/trucks/#{@foodtruck_id}'>#{foodtruck['name']}</a>"
    end
  end
end

Liquid::Template.register_tag('foodtruck', Jekyll::FoodTruckTag)
