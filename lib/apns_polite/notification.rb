# encoding: utf-8

module ApnsPolite

	require 'socket'
	require 'openssl'

	class Notification
		# 初期化
		def initialize(options = nil)
			if options
				host = options[:host]
				pem = options[:pem]
				port = options[:port]
				password = options[:password]

				connection host, port, pem, password
			end
		end
		# 接続
		def connection(host, port, pem, password=nil)

			@host = host || 'gateway.sandbox.push.apple.com'
			@port = port || 2195
			@pem = pem
			@password = password

			reconnection
		end
		# 再接続
		def reconnection
			close

			raise "The path to your pem file is not set." unless @pem
			raise "The path to your pem file does not exist!" unless File.exist?(@pem)

			pemText = File.read @pem

			context = OpenSSL::SSL::SSLContext.new
			context.cert = OpenSSL::X509::Certificate.new pemText
			context.key = OpenSSL::PKey::RSA.new pemText, @password

			sock = TCPSocket.new @host, @port
			ssl = OpenSSL::SSL::SSLSocket.new sock, context
			ssl.connect

			@sock = sock
			@ssl = ssl
		end
		# 切断
		def close
			@ssl.close if @ssl
			@sock.close if @sock

			@ssl = nil
			@sock = nil
		end
		# 通知
		def push(message)
			raise "No connected." unless @ssl
			@ssl.write message.pack
		end

	end

end # end of module

