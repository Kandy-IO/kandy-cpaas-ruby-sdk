require 'dotenv'
require 'rubygems'
require 'bundler'

require './app'
require './helper'

initial_setup

Bundler.require
Dotenv.load

run App
