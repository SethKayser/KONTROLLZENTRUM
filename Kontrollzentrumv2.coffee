command: "echo 'READY'"
refreshFrequency: false

style: """
  top: 20px
  right: 20px
  width: 620px
  font-family: 'Courier New', monospace
  color: #FFFFFF

  .kz-root
    border: 1px solid rgba(255, 255, 255, 0.1)
    background: rgba(20, 20, 20, 0.4) 
    backdrop-filter: blur(20px) 
    border-radius: 24px 
    display: flex
    flex-direction: column
    position: relative
    overflow: hidden
    box-shadow: 0 20px 50px rgba(0,0,0,0.3)

  .kz-scanline
    position: absolute; top: 0; left: 0; right: 0; bottom: 0
    background: linear-gradient(to bottom, rgba(255,255,255,0.03) 0%, transparent 100%)
    pointer-events: none; z-index: 1

  .kz-header
    width: 100%
    height: 32px
    border-bottom: 1px solid rgba(255, 255, 255, 0.15)
    display: flex
    justify-content: center
    align-items: center
    padding: 0 15px
    background: rgba(255, 255, 255, 0.03)
    box-sizing: border-box
    position: relative

  .kz-status-container
    position: absolute
    right: 15px
    font-size: 8px
    letter-spacing: 1px
    display: flex
    align-items: center
    gap: 6px
    opacity: 0.6

  .kz-dot
    width: 5px; height: 5px; background: #FFF; border-radius: 50%
    box-shadow: 0 0 8px #FFF

  .kz-main-grid
    display: grid
    grid-template-columns: 240px 1fr
    gap: 20px
    padding: 20px 20px 5px 20px

  .kz-panel-left
    display: flex
    flex-direction: column
    align-items: center
    text-align: center

  .kz-clock
    font-size: 42px
    font-weight: 600
    color: #FFFFFF
    width: 100%
    letter-spacing: 0.5px

  .kz-card
    border: 1px solid rgba(255, 255, 255, 0.1)
    padding: 10px; background: rgba(255, 255, 255, 0.02)
    margin-bottom: 10px; width: 100%; box-sizing: border-box; text-align: left

  .kz-label
    font-size: 9px; opacity: 0.7; letter-spacing: 2px; text-transform: uppercase
    margin-bottom: 5px; color: #FFFFFF

  .kz-value
    font-size: 16px; font-weight: bold; color: #FFFFFF; letter-spacing: 1px

  #gol-canvas
    width: 100%
    height: 120px
    background: rgba(255, 255, 255, 0.02)
    display: block
    margin-top: 5px
    cursor: crosshair

  .kz-panel
    display: flex; flex-direction: column

  .kz-apod-img
    width: 100%; height: 260px; object-fit: cover
    border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 4px

  #kz-apod-title
    font-size: 10px; margin-top: 4px; opacity: 0.8; letter-spacing: 1px

  .kz-footer
    padding: 10px 20px; border-top: 1px solid rgba(255,255,255,0.1)
    text-align: center; background: rgba(255,255,255,0.01)
    
  .de-text
    font-size: 12px; font-style: italic; margin: 0
    
  .en-text
    font-size: 10px; color: rgba(255,255,255,0.5); margin-top: 4px; text-transform: uppercase; letter-spacing: 1px
"""

render: -> """
  <div class="kz-root">
    <div class="kz-scanline"></div>
    <div class="kz-header">
      <div style="font-size: 11px; letter-spacing: 4px; font-weight: bold;">KONTROLLZENTRUM</div>
      <div class="kz-status-container">
        <div class="kz-dot"></div>
        <span>NOMINAL</span>
      </div>
    </div>
    <div class="kz-main-grid">
      <div class="kz-panel-left">
        <div class="kz-clock" id="kz-clock">00:00:00</div>
        <div style="font-size:11px; opacity:0.6; letter-spacing:2px; margin-bottom:20px" id="kz-date">--------</div>
        <div class="kz-card">
          <div class="kz-label">WETTERBERICHT</div>
          <div class="kz-value" id="kz-weather">LOCALIZING...</div>
        </div>
        <div class="kz-card">
          <div class="kz-label">ZELLULÄRE AUTOMATEN · GEN <span id="gol-gen">0</span></div>
          <canvas id="gol-canvas"></canvas>
        </div>
      </div>
      <div class="kz-panel">
        <div class="kz-label">NASA MISSION FEED</div> 
        <img class="kz-apod-img" id="kz-apod-img" src="">
        <div id="kz-apod-title">LOADING...</div>
      </div>
    </div>
    <div class="kz-footer">
      <div id="quote-de" class="de-text">...</div>
      <div id="quote-en" class="en-text">...</div>
    </div>
  </div>
"""

afterRender: (domEl) ->
  return if domEl.__kzStarted
  domEl.__kzStarted = true

  # Settings
  speed = 100; spawnChance = 0.8; autoReboot = 2000; entity_size = 4
  
  # State
  observer = { lat: 0, lon: 0 } # Default to 0 until GPS kicks in
  getEl = (s) -> domEl.querySelector(s)
  setText = (s, v) -> getEl(s)?.textContent = v

  # Game of Life Logic
  canvas = getEl('#gol-canvas'); ctx = canvas.getContext('2d')
  canvas.width = 220; canvas.height = 120
  ex = Math.ceil(canvas.width / entity_size); ey = Math.ceil(canvas.height / entity_size)
  num = ex * ey; it = 0; ent = new Array(num); nent = new Array(num)
  offs = [-1-ex, -ex, 1-ex, -1, 1, -1+ex, ex, 1+ex]

  initialise = ->
    it = 0
    for i in [0...num]
      ent[i] = if Math.random() > spawnChance then 1 else 0
      nent[i] = ent[i]

  step = ->
    for i in [0...num]
      live = 0
      for j in offs
        idx = i + j
        x = idx % ex; y = Math.floor(idx / ex)
        if x < 0 then x = ex + x
        if y < 0 then y = ey + y
        if x >= ex then x = x - ex
        if y >= ey then y = y - ey
        if ent[y * ex + x] is 1 then live += 1
      if ent[i] is 1 then nent[i] = if live < 2 or live > 3 then 0 else 1
      else nent[i] = if live is 3 then 1 else 0
    [ent, nent] = [nent, ent]
    it++; if it > autoReboot then initialise()
    ctx.clearRect(0, 0, canvas.width, canvas.height); ctx.fillStyle = "white"
    for i in [0...num]
      if ent[i] is 1 then ctx.fillRect((i % ex) * entity_size, Math.floor(i / ex) * entity_size, entity_size - 1, entity_size - 1)
    setText('#gol-gen', it)

  # API Fetchers
  fetchJSON = (url) -> fetch(url).then (r) -> r.json()

  fetchWeather = ->
    return if observer.lat is 0
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{observer.lat}&longitude=#{observer.lon}&current_weather=true"
    fetchJSON(url).then (d) -> 
      if d.current_weather?
        setText('#kz-weather', "#{Math.round(d.current_weather.temperature)}°C · NOMINAL")

  fetchNASA = ->
    rss = "https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss"
    api = "https://api.rss2json.com/v1/api.json?rss_url=#{encodeURIComponent(rss)}"
    fetchJSON(api).then (data) ->
      if data.items?.length > 0
        getEl('#kz-apod-img').src = data.items[0].enclosure.link
        setText('#kz-apod-title', data.items[0].title.toUpperCase())

  fetchQuote = ->
    now = Date.now(); cached = JSON.parse(localStorage.getItem('kz_shared_cache') or '{}')
    if cached.de and (now - cached.time < 3600000)
      setText('#quote-de', cached.de); setText('#quote-en', cached.en)
    else
      fetchJSON('https://api.zitat-service.de/v1/quote?language=de').then (d) ->
        url = "https://translate.googleapis.com/translate_a/single?client=dict-chrome-ex&sl=de&tl=en&dt=t&q=#{encodeURIComponent(d.quote)}"
        fetch(url).then( (r) -> r.json() ).then (trans) ->
          en = (s[0] for s in trans[0]).join(' ').toUpperCase()
          localStorage.setItem 'kz_shared_cache', JSON.stringify({de: d.quote, en: en, time: now})
          setText('#quote-de', d.quote); setText('#quote-en', en)

  # Main Init
  initialise()
  setInterval(step, speed)
  setInterval((-> 
    n = new Date()
    setText('#kz-clock', n.toLocaleTimeString('en-GB'))
    setText('#kz-date', n.toDateString().toUpperCase())
  ), 1000)

  fetchNASA(); setInterval(fetchNASA, 21600000)
  fetchQuote(); setInterval(fetchQuote, 300000)

  # Geolocation
  if navigator.geolocation?
    navigator.geolocation.getCurrentPosition (p) ->
      observer = { lat: p.coords.latitude, lon: p.coords.longitude }
      fetchWeather(); setInterval(fetchWeather, 600000)