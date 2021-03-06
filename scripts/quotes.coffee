# Description:
#   Quotes allows you to quote text and save it for later.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot quote add <quote> - Saves the quote
#   hubot quote read # - Reads the quote stored
#   hubot quote list - Lists all quotes
#   hubot quote find <string> - Lists all quotes that contain the search string
#   hubot quote random - Reads a random quote
#

brainLoaded = false
quotes = []
random = (min, max) -> 
  Math.floor(Math.random() * (max - min + 1)) + min;

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    if(brainLoaded)
      return
    brainLoaded = true
    quotes = robot.brain.get("quotes")
    if not quotes
      quotes = []
      robot.brain.set("quotes", quotes)
      robot.brain.save()

  robot.respond /quote add ([\S\s]*)/i, (msg) ->
    if brainLoaded
      quote = {who: msg.message.user['name'], quote: msg.match[1].trim()}
      quotes.push(quote)
      robot.brain.set("quotes", quotes)
      robot.brain.save()
      msg.send("Saved quote as quote #{quotes.length}.")

  robot.respond /quote read ([0-9]+)/i, (msg) ->
    if brainLoaded
      quoteIndex = parseInt(msg.match[1])
      if quoteIndex > 0 and quoteIndex <= quotes.length
        quote = quotes[quoteIndex - 1]
        msg.send("##{quoteIndex}: #{quote.quote} - _Added by #{quote.who}_")
      else
        msg.send("Invalid quote.")

  robot.respond /quote list/i, (msg) ->
    if brainLoaded
      msg.send("https://tshock-hubot.herokuapp.com/quotes/")

  robot.respond /quote find (.*)/i, (msg) ->
    if brainLoaded
      foundQuotes = []
      for index of quotes
        if quotes[index].quote.toLowerCase().indexOf(msg.match[1].toLowerCase()) isnt -1
          foundQuotes.push(++index)
      if foundQuotes.length > 1
        msg.send("Found #{foundQuotes.length} quotes: #{foundQuotes.join()}.")
      else if foundQuotes.length > 0
        msg.send("Found one quote: #{foundQuotes[0]}.")
      else
        msg.send("Did not find any matches (potato).")

  robot.respond /quote random/i, (msg) ->
    if brainLoaded
      if quotes.length > 0
        quoteIndex = random(1, quotes.length)
        quote = quotes[quoteIndex - 1]
        msg.send("##{quoteIndex}: #{quote.quote} - _Added by #{quote.who}_")
      else
        msg.send("You have no quotes, nerd. (kappa)")

  robot.respond /quote delete ([0-9]+)/i, (msg) ->
    if brainLoaded
      quoteIndex = parseInt(msg.match[1])
      if (quoteIndex > 0 and quoteIndex <= quotes.length)
        quotes.splice(quoteIndex - 1, 1)
        msg.send("Deleted quote #{quoteIndex}")
      else
        msg.send("Invalid quote.")

  robot.router.get '/quotes/?', (req, res) ->
    res.json (quotes)
