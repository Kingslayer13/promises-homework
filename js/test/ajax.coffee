define ['chai', 'sinon', 'jquery'], ({expect}, sinon, $) ->

    describe 'Promises', ->
        server = sinon.fakeServer.create()
        server.respondWith 'GET', '/users', [200, {"Content-Type": "application/json"}, JSON.stringify([{name: 'Jack'},{name: 'Bob'}])]
        server.respondWith 'GET', '/cars',  [200, {"Content-Type": "application/json"}, JSON.stringify([{name: 'BMW'},{name: 'VW'}])]
        server.respondWith 'GET', '/phones', [200, {"Content-Type": "application/json"}, JSON.stringify([{name: 'iPhone'},{name: 'Lenovo'}])]

        it 'should response on ajax request', (done) ->
            usersPromise = $.get '/users', ->
            usersPromise.done (users)->
                arguments
                expect(users).to.deep.equal [{name: 'Jack'},{name: 'Bob'}]

            carsPromise = $.get '/cars'
            carsPromise.done (cars, statusText, jqXHR)->
                expect(jqXHR).to.be.equal(carsPromise)
                expect(cars).to.deep.equal [{name: 'BMW'},{name: 'VW'}]

            phonesPromise = $.get '/phones'
            phonesPromise.done (phones)->
                expect(phones).to.deep.equal [{name: 'iPhone'},{name: 'Lenovo'}]

            totalPromise = $.when(carsPromise, usersPromise, phonesPromise)

            totalPromise.done (carsArguments, usersArguments, phonesArguments) ->
                expect([carsArguments[0], usersArguments[0], phonesArguments[0]]).to.deep.equal [
                    [{name: 'BMW'},{name: 'VW'}]
                    [{name: 'Jack'},{name: 'Bob'}]
                    [{name: 'iPhone'},{name: 'Lenovo'}]
                ]

            totalPromise.fail (xhr) ->
                expect(xhr).to.be.equal(carsPromise)

            totalPromise.always ->
                done()

            server.respond()

        it 'should create promise and execute it', (done)->
            timeout = ->
                defered = new $.Deferred()

                setTimeout (->
                    defered.resolve('test', 10)
                ), Math.round(2000 * Math.random())

                setTimeout (->
                    defered.reject('error', {message: 'Fuck'})
                ), Math.round(2000 * Math.random())

                setInterval (->
                    defered.notify('in progress...')
                ), 50

                return [defered.promise(), defered.promise()]

            [promise, secondPromise] = timeout()

            console.log promise

            promise.done (args...)->
                expect(args).to.deep.equal ['test', 10]

            promise.fail (args...)->
                expect(args).to.deep.equal ['error', {message: 'Fuck'}]

            promise.progress (args...)->
                console.log args

            promise.always ->
                console.log arguments
                done()

            secondPromise.always ->
                console.log arguments