require 'json'

class Flash

  def initialize(req)
    unless req.cookies['_rails_lite_app_flash'].nil?
      @flash_in = JSON.parse(req.cookies['_rails_lite_app_flash'])
    end
    @flash_in ||= {}
    @flash_out = {}
    @flash_now = {}
  end

  def [](key)
    @flash_now[key] || @flash_out[key] || @flash_in[key]
  end

  def []=(key, val)
    @flash_out[key] = val
  end

  def now
    @flash_now
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', {
      path: '/',
      value: @flash_out.to_json
    })
  end

end
