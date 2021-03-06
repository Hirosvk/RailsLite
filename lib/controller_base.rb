require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(@req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !@already_built_response.nil?
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double Render Error" if already_built_response?
    @res['Location'] = url
    @res.status = 302
    @already_built_response = @res

    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double Render Error" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = @res

    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_match = self.class.name.match(/^(\w+)(Controller)$/)
    controller_folder = "#{controller_match[1]}_#{controller_match[2]}".downcase

    template = File.read("views/#{controller_folder}/#{template_name}.html.erb")
    final_html = ERB.new(template).result(binding)
    render_content(final_html, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end

  def flash
    @flash ||= Flash.new(@req)
  end

end
