require 'erb'

class ShowExceptions
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue => e
      res = Rack::Response.new
      ["500", {'Content-type' => 'text/html'}, render_exception(e) ]
    end
  end

  private

  def render_exception(e)
    error_file = File.read('lib/templates/rescue.html.erb')
    ERB.new(error_file).result(binding)
  end

end
