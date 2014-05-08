Jobist.configure do
  queue :discogs, consumers: 10, throttle: {1 => 1.second}
  queue :last_fm, consumers: 10, throttle: {10 => 1.second}
  queue :index, consumers: 10
end
