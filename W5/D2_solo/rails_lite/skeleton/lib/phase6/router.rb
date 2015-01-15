require 'byebug'

module Phase6
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern = pattern
      @http_method = http_method
      @controller_class = controller_class
      @action_name = action_name
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      return false unless pattern.is_a?(Regexp)

      !(self.pattern.match(req.path)).nil? && self.http_method == req.request_method
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      regex = Regexp.new(self.pattern)
      hash = regex.match(req.path)
      r_params = Hash[hash.names.zip(hash.captures)]

      controller = self.controller_class.new(req, res, r_params)
      controller.invoke_action(self.action_name)
    end
  end

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      self.routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      router = Phase6::Router.new
      router.draw do
        get Regexp.new("^/cats$"), Cats2Controller, :index
        get Regexp.new("^/cats/(\\d+)/statuses$"), StatusesController, :index
      end
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern,
                  http_method,
                  controller_class,
                  action_name)
      end
    end

    # should return the route that matches this request
    def match(req)
      match = nil
      @routes.each do |route|
        if route.matches?(req)
          match = route
        end
      end

      match
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      match = match(req)

      if match.nil?
        res.status = 404
      else
        match.run(req, res)
      end
    end
  end
end
