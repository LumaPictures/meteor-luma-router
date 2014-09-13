Package.describe({
  name: "luma:router",
  summary: "Database driven routes and utilities for Iron-Router",
  git: "https://github.com/LumaPictures/meteor-luma-router",
  version: "0.0.9"
});

Package.onUse(function (api) {
  if (api.versionsFrom)
    api.versionsFrom('METEOR@0.9.0');

  api.use([
    'coffeescript',
    'underscore',
    'iron:router@0.9.3',
    'meteorhacks:subs-manager@1.1.0'
  ],[ 'client', 'server' ]);

  // for helpers
  api.use([
    'jquery',
    'ui',
    'templating',
    'spacebars'
  ], [ 'client' ]);

  api.export([
    'Luma',
    'Router'
  ], ['client','server']);

  api.add_files([
    'lib/luma-router.coffee'
  ], [ 'client', 'server' ]);

  api.add_files([
    'lib/components/anchor/anchor.component.html',
    'lib/components/anchor/anchor.component.coffee'
  ], [ 'client' ]);
});

Package.onTest(function (api) {
  api.use([
    'coffeescript',
    'luma:router',
    'tinytest',
    'test-helpers'
  ], ['client', 'server']);

  api.add_files([
    'tests/luma-router.test.coffee'
  ], ['client', 'server']);
});