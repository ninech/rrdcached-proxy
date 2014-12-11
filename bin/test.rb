#!/usr/bin/env ruby

require 'mkfifo'

APP_ROOT = File.expand_path('../../', __FILE__)

fifo_path = File.join(APP_ROOT, 'test.fifo')

File.mkfifo fifo_path unless File.exists?(fifo_path)

loop do
  File.open(fifo_path).each do |line|
    puts line
  end
end

