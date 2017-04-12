#!/usr/bin/env ruby
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'handler'

handler = Handler.new.update
