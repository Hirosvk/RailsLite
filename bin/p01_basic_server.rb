require 'rack'

  loveaa = Proc.new do |env|
    req = Rack::Request.new(env)
    res = Rack::Response.new
    p req.path
    p req.cookies
    if req.path =~ /^\/i\/love\/appacademy/
      res.write("I love App Academy")
    else
      res.write("I guess you don't love App Academy")
    end
    res['Content-Type'] = 'text/html'
    res.finish
  end


Rack::Server.start(
  app: loveaa,

  Port: 8080
)
