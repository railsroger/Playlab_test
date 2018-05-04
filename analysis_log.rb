#!/usr/bin/env ruby

# Regular expression for a string in a log.
HEROKU_REGEX = /.+: at=\w+ method=(\w+) path=(.+) host=.+ fwd=.+ dyno=(.+) connect=(\d+)ms service=(\d+)ms status=\d+ bytes=\d+/

# Reading with the entered address of the log.
log_lines = File.readlines ARGV.first

def parse(lines)
  urls = {}
  response_times = []
  dynos = {}

  lines.each do |line|
    parsed_line = line.scan(HEROKU_REGEX)[0]

    # If can't parse the log line for any reason.
    if line.scan(HEROKU_REGEX)[0].nil?
      puts "Can't parse: #{line}\n\n"
      next
    end

    # Convert url to a common view.
    url = parsed_line[1].gsub(/\d+/,'USER_ID')

    # The number of times the URL was called.
    if urls.has_key?(url)
      urls[url] += 1
    else
      urls[url] = 1
    end

    # All dyno List
    dyno = parsed_line[2]

    # How many times did dyno respond.
    if dynos.has_key?(dyno)
      dynos[dyno] += 1
    else
      dynos[dyno] = 1
    end

    # Convert arrays to integer.
    connect = parsed_line[3].to_i
    service = parsed_line[4].to_i

    # Mode of the response time (connect time + service time).
    response_times << connect + service
  end

  # The mean (average).
  def mean(arr)
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  # The median.
  def median(array)
    sorted = array.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  # The dyno that responded the most.
  def most_responsive_dyno(most)
    most.sort {|a,b| a[1] <=> b[1] }.last
  end

  # Output of results: urls, mean, median, responsed the most dyno.
  puts "The number of times the URL was called - #{urls}"
  puts "Mean - #{mean(response_times)}"
  puts "Median - #{median(response_times)}"
  puts "The dyno that responded the most - #{most_responsive_dyno(dynos)}"
  puts response_times
end

require 'pp'
pp parse(log_lines)