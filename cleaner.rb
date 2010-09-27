#!/usr/bin/env ruby

# Hoptoad Cleaner
#
# A simple "Resolve All" script for Hoptoad
#
# http://github.com/vegetables/hoptoad-cleaner
# @author Matt Venables <mattvenables@gmail.com>

API_KEY = 'abc123abc123abc123'
SUBDOMAIN = 'my-app'

require 'rubygems'
require 'rest_client'
require 'crack'

module Vegetables
  module Hoptoad
    class Cleaner
      attr_accessor :key, :site
      
      def initialize(key, site)
        @key, @site = key, site
      end
      
      def url(error_id=nil)
        url = "http://#{@site}.hoptoadapp.com/errors"
        url += "/#{error_id}" unless error_id.nil?
        url += "?auth_token=#{@key}"
      end
            
      def clean        
        errors = self.get_errors
        return if errors.nil? || errors.empty?
                
        errors.each { |error| self.resolve error }
        self.clean
      end
      
      def get_errors
        data = RestClient.get(url) || ''
        parsed_data = Crack::XML.parse(data) || {}
        parsed_data['groups']
      end
      
      def resolve(error)
        puts "Resolving #{error['id']}: #{error['error_message']}"
        RestClient.put(url(error['id']), :group => { :resolved => true }, :auth_token => @key)
      end
      
    end
  end
end

cleaner = Vegetables::Hoptoad::Cleaner.new(API_KEY, SUBDOMAIN)
cleaner.clean