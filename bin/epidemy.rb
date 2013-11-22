#!/usr/bin/env ruby
# epydemy.rb

# lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
# $LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

# require 'byebug'
# byebug
# require_relative '../lib/epidemy'
# require 'epidemy'

require "bundler/setup"
Bundler.require

$: << "./lib"

require 'epidemy'

base = Epidemy::Base.new
base.default ARGV
