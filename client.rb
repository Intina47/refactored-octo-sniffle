# client.rb
require 'socket'

begin
    socket = nil
    until socket
        begin
            socket = TCPSocket.new('localhost', 2345)
        rescue Errno::ECONNREFUSED
            puts "Connection failed, trying again..."
            sleep 2
        end
    end

    while true
        print "Enter a message: "
        message = gets.chomp
        break if message == "exit"

        socket.puts message
        puts "Sent: #{message}"
        response = socket.gets
        puts "Server said: #{response}"
    end

    puts "Connection closed"
rescue Errno::EPIPE
    puts "Server has closed the connection"
ensure
    socket.close if socket
end