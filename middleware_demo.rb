require 'rack'

class LoggerMiddleware
  attr_reader :app

  def initialize(app)
    p "Initializing logger"
    @app = app
  end

  def call(env)
    p "Calling logger"
    write_log(env)
    app.call(env)
    # the above line execute the next middleware in the stack,
    # which is 'cool_app' in this case.
  end

  private

  def write_log(env)
    req = Rack::Request.new(env)
    log_file = File.open('application.log', 'a')

    log_text = <<-LOG
    Time: #{Time.now}
    IP: #{req.ip}
    Path: #{req.path}
    User Agent: #{req.user_agent}
    LOG

    log_file.write(log_text)
    log_file.close
  end
end

class BrowserFilter
  attr_reader :app
  def initialize(app)
    p "initializing Filter"
    @app = app
  end

  def call(env)
    p "calling Filter"
    req = Rack::Request.new(env)
    res = Rack::Response.new

    if req.user_agent.include?("MSIE")
      res.status = 302
      res['Location'] = 'https://www.google.com/chrome/'
      res.finish
      # notice that app.call(env) is in the 'else' clause.
      # res.finish doesn't send the response.
    else
      app.call(env)
      # this calls the next middleware in the stack,
      # which is Logger.
    end
  end
end


class ShowExceptions
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
      # This runs 'cool_app'. When Exception is raised,
      # it catches in the blow code. When the exception is raised,
      # that means that not response was sent to the client. So,
      # here 'res.finish' is sent to avoid "internal server errors."
    rescue => e
      res = Rack::Response.new
      res.write(e.message)
      res.finish
    end
  end

end



cool_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  file = File.open('index.html.erb', 'r')
  lines = file.read

  res['Content-Type'] = 'text/html'
  res.write(lines)

  res.finish
end

app = Rack::Builder.new do
  use BrowserFilter
  use LoggerMiddleware
  use ShowExceptions
  run cool_app
end.to_app

Rack::Server.start({
  app: app,
  Port: 3000
})
