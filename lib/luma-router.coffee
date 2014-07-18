# luma-router
@Luma = Luma = unless Luma then {}
Luma.Router = Router
Luma.Controllers = Base: RouteController
# Routes
# ======
# `luma-router` uses db driven routes to enable simple management of routes from an administrative backend.
# [An example route db collection can be seen here](../example/server/init_pages.coffee)
Luma.Router.collection = new Meteor.Collection 'Route'

# Routes cannot be modified by the client by default

Luma.Router.collection.allow
  insert: -> false
  update: -> false
  remove: -> false

# Currently all routes are published to the client by default
# TODO : take user permissions into account when publishing routes
Luma.Router.publish = ->
  if Meteor.isServer
    Meteor.publish "all_routes", -> Luma.Router.collection.find()

Luma.Router.addRoutes = ( routes ) ->
  if Meteor.isServer
    Meteor.startup ->
      count = 0
      _.each routes, ( route ) ->
        unless route.controller
          route.controller = null
        unless route.external
          route.external = false
        Luma.Router.collection.upsert { route: route.route }, { $set: route }
        count++
      console.log( count + ' routes inserted')

# A simple route object :
###
```coffeescript
{
  route: 'home'
  path: '/'
  controller: 'ExampleController'
  page:
    title: "Home"
    subtitle: "This isn't really home, its work."
}
```
###

# Note that the controller is specified on the route, and that `page` is a context that will be used, most likely in the page header.

# A more complex route :

###
```coffeescript
{
  route: "forms"
  path: "/forms"
  controller: 'ExampleController'
  nav:
    priority: 9
    icon: 'icon-stack'
    children: [{
      title: 'Form Snippets'
      route: 'formSnippets'
      children: [{
        title: 'Bug Report Form'
        route: 'bugReportForm'
      }]
    },{
      title: 'Form Components'
      route: 'formComponents'
      children: [{
        title: 'Form Elements'
        route: 'formElements'
        children: [{
          title: 'Basic Inputs'
          route: 'basicInputs'
        }]
      },{
        title: 'WYSIWYG Editors'
        route: 'wysiwygEditors'
      }]
    }]
  page:
    title: 'Forms'
    subtitle: 'A necessary evil'
  callouts: [
    cssClass: "callout-success"
    title: "We All Hate Filling Out Forms"
    message: "Time to change that."
  ]
}
```
###

# Here the route also has a `nav` context, which is used in the example by the `sidebar_content` yield.
# To see how the yield parses the context see the [default_sidebar_content component](../components/sidebar/default_sidebar_content.html)

# Initial router configuration
Luma.Router.initialized = false

if Meteor.isClient
  Luma.Router.managers =
    global: new SubsManager cacheLimit: 9999, expireIn: 9999

  Luma.Router.subscriptions =
    all_routes: ( callback = null ) ->
      global = Luma.Router.managers.global
      return global.subscribe 'all_routes', callback

Luma.Router.initialize = ->
  if Meteor.isServer
    Luma.Router.publish()
  if Meteor.isClient
    Luma.Router.configure
      # disable rendering until subscription is ready
      autoStart: false
      notFoundTemplate: "error404"
      loadingTemplate: "loading"
      waitOn: ->
        handles = []
        handles.push subscription() for key, subscription of Luma.Router.subscriptions
        return handles
    # when the 'all_routes' subscription is ready
    Luma.Router.subscriptions.all_routes ->
      # if the router has not been initialized yet
      unless Luma.Router.initialized
        Luma.Router.map ->
          self = @
          # add each route in the all pages collection to the router
          Luma.Router.collection.find().forEach ( route ) ->
            unless route.external is "true"
              self.route route.route, route
        Luma.Router.initialized = true
        Luma.Router.start()

Luma.Router.getNavItems = ->
  Luma.Router.collection.find { 'nav.priority': { $gt: 0 } },{ sort: { 'nav.priority': 1 } }

Luma.Router.getRoute = ( route_name ) ->
  route = Luma.Router.collection.find( { route: route_name }, { limit : 1 } )
  if route.count()
    return route.fetch()[0]
  else throw new Error "Route for `#{ route_name }` not found."

Luma.Router.regex = ( expression ) -> new RegExp expression, "i"

Luma.Router.testRoutes = ( routeNames ) ->
  reg = Luma.Router.regex routeNames
  return Router.current() and reg.test Router.current().route.name

Luma.Router.testPaths = ( paths ) ->
  reg = Luma.Router.regex paths
  return Router.current() and reg.test Router.current().path

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