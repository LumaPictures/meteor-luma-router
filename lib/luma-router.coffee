# luma-router
@Luma = Luma = unless Luma then {}
Luma.Router = Router
Luma.Controllers = Base: RouteController
# Routes

# Currently all routes are published to the client by default
# TODO : take user permissions into account when publishing routes

# Here the route also has a `nav` context, which is used in the example by the `sidebar_content` yield.
# To see how the yield parses the context see the [default_sidebar_content component](../components/sidebar/default_sidebar_content.html)

# Initial router configuration
Luma.Router.initialized = false

if Meteor.isClient
  Luma.Router.managers =
    global: new SubsManager cacheLimit: 9999, expireIn: 9999

  Luma.Router.subscriptions = {}

  Luma.Router.configure
    # disable rendering until subscription is ready
    notFoundTemplate: "error404"
    loadingTemplate: "loading"
    waitOn: ->
      handles = []
      handles.push subscription() for key, subscription of Luma.Router.subscriptions
      return handles

Luma.Router.getNavItems = ->
  routes = []
  for route in Luma.Router.routes
    routes.push route if route.options.nav
  return routes

Luma.Router.getRoute = ( name ) -> return Luma.Router.routes[ name ] or false

Luma.Router.regex = ( expression ) -> new RegExp expression, "i"

Luma.Router.testRoutes = ( routeNames ) ->
  reg = Luma.Router.regex routeNames
  return Luma.Router.current() and reg.test Luma.Router.current().route.name

Luma.Router.testPaths = ( paths ) ->
  reg = Luma.Router.regex paths
  return Luma.Router.current() and reg.test Luma.Router.current().path

Luma.Router.isActiveRoute = ( routes, className ) ->
  className = className or "active"
  if Luma.Router.testRoutes routes
    return className
  else return false

Luma.Router.isActivePath = ( paths, className ) ->
  className = className or "active"
  if Luma.Router.testPaths paths
    return className
  else return false

Luma.Router.isNotActiveRoute = ( routes, className ) ->
  className = className or "disabled"
  if not Luma.Router.testRoutes routes
    return className
  else return false

Luma.Router.isNotActivePath = ( paths, className ) ->
  className = className or "disabled"
  if not Luma.Router.testPaths paths
    return className
  else return false

if Meteor.isClient
  UI.registerHelper "isActiveRoute", ( routes, options ) ->
    options = options.hash or {}
    className = options.className or null
    return Luma.Router.isActiveRoute( routes, className ) or null

  UI.registerHelper "isActivePath", (paths, options) ->
    options = options.hash or {}
    className = options.className or null
    return Luma.Router.isActivePath( paths, className ) or null

  UI.registerHelper "isNotActiveRoute", (routes, options) ->
    options = options.hash or {}
    className = options.className or null
    return Luma.Router.isNotActiveRoute( routes, className ) or null

  UI.registerHelper "isNotActivePath", (paths, options) ->
    options = options.hash or {}
    className = options.className or null
    return Luma.Router.isNotActivePath( paths, className ) or null