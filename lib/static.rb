class Static
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    if req.path.start_with?("/public")
      begin
        file = File.read(req.path[1..-1])
        # require 'byebug'; debugger
        res.write(file)
        res.finish
      rescue => e
        res.status = '404'
        res.write(e.message)
        res.finish
      end
    else
      app.call(env)
    end
  end
end
