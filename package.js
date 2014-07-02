Package.describe({
  summary: "Database driven routes and utilities for Iron-Router"
});

Package.on_use(function (api, where) {
  api.use([
    'coffeescript',
    'underscore',
    'iron-router'
  ],[ 'client', 'server' ]);

  // for helpers
  api.use([
    'jquery',
    'ui',
    'templating',
    'spacebars'
  ], [ 'client' ]);

  api.export([
    'Luma'
  ], ['client','server']);

  api.add_files([
    'lib/luma-router.coffee'
  ], [ 'client', 'server' ]);

  api.add_files([
    'lib/components/anchor/anchor.component.html',
    'lib/components/anchor/anchor.component.coffee'
  ], [ 'client' ]);
});

Package.on_test(function (api) {
  api.use([
    'coffeescript',
    'luma-router',
    'tinytest',
    'test-helpers'
  ], ['client', 'server']);

  api.add_files([
    'tests/luma-router.test.coffee'
  ], ['client', 'server']);
});