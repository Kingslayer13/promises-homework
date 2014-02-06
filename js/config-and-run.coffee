require.config
    baseUrl: 'js/'
    paths:
        jquery: 'lib/jquery/jquery.min'
        mocha: 'lib/mocha/mocha'
        chai: 'lib/chai/chai'
        sinon: 'lib/sinonjs/sinon'

    shim:
        jquery:
            exports: 'jQuery'

        mocha:
            exports: 'mocha'

        sinon:
            exports: 'sinon'

tests = [
    'ajax'
]

tests = tests.map (test) -> 'test/' + test

require ['mocha'], (mocha) ->
    mocha.setup 'bdd'
    require tests, ->
        mocha.run()