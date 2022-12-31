require 'libusb'

ctx = LIBUSB::Context.new
puts "devices:"
dev = ctx.devices[1]
puts dev.inspect

# Open handle
handle = dev.open
timeout = 5000
# Urb 0x02 open
puts "URB 0x02"
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x02, wValue: 0x02, wIndex: 0x00, timeout: timeout)

# Flush
raise "Flush failed" unless handle.control_transfer(bmRequestType: 0x40, bRequest: 0x02, wValue: 0x01, wIndex: 0x00, timeout: timeout) == 0
# Send and recv
readbytes = 64
while command = readline.chomp
  break if command =~ /^quit/
  # Flushing
  puts "Flushing buffer"
  begin
    result = handle.bulk_transfer(endpoint: 0x82, dataIn: 4096, timeout: timeout)
    puts result
  rescue
      puts "Didn't flush xxit"
  end
  puts "Command #{command}"
  command += "\x00"
  result = handle.bulk_transfer(endpoint: 0x02, dataOut: command, timeout: timeout)
  puts "#{result} bytes went out"
  #puts "Reading result:"

  result = handle.bulk_transfer(endpoint: 0x82, dataIn: readbytes, timeout: timeout)
  #puts result

  puts "--Result--"
  puts result.split("\0")[0]
  puts "----------"
end
# Close
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x02, wValue: 0x04, wIndex: 0x00, timeout: timeout)
handle.close