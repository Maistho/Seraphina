#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rules.rb'
STD_LIB = File.read(File.dirname(__FILE__)+"/stl.sp")
file = ARGV[0]

if file != nil
	seraphina = Seraphina.new
	seraphina.parse(File.read(file))
	seraphina.run()
	puts "\n"
end
