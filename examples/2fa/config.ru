require 'dotenv'
require 'rubygems'
require 'bundler'

require './app'

Bundler.require
Dotenv.load

run App
