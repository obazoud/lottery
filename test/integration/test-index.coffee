vows = require 'vows'
request = require 'request'
assert = require 'assert'
phantom = require 'phantom'

describe = (name, bat) -> vows.describe(name).addBatch(bat).export(module)

t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

describe "Lottery index"
  "When open a page":
    topic: t ->
      test = this
      phantom.create (p) ->
        p.createPage (page) ->
          test.callback null, page, p
    "and GET to /":
      topic: t (page) ->
        page.open "http://127.0.0.1:3000/", (status) =>
          @callback null, page, status

      "and succeed": (err, page, status) ->
        assert.equal status, "success"

      "and the page, once it loads,":
        topic: t (page) ->
          setTimeout =>
            @callback null, page
          , 1000

        "has a title":
          topic: t (page) ->
            page.evaluate (-> document.title), (title) => @callback null, title

          "which is correct": (title) ->
            assert.equal title, "Web tambouille Contest 2012"

        "has navbar":
          topic: t (page) ->
            page.evaluate (-> $("div .navbar-fixed-top").length), (navbar) => @callback null, navbar

          "which exists": (navbar) ->
            assert.equal navbar, 1

        "has navbar title":
          topic: t (page) ->
            page.evaluate (-> $("div .navbar-fixed-top a.brand").text()), (title) => @callback null, title
          
          "which exists": (title) ->
            assert.equal title, "Loterie"

        "has footer":
          topic: t (page) ->
            page.evaluate (-> $("footer").length), (footer) => @callback null, footer

          "which exists": (footer) ->
            assert.equal footer, 1

    teardown: (page, ph) ->
      ph.exit()
