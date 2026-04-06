# KONTROLLZENTRUM (Control Center)

A high-contrast, retro-terminal style desktop widget for macOS, built for the Übersicht platform. This widget provides a real-time mission-control experience with live data feeds, cellular automata, and language integration.

---

## Features

* **Live Clock & Date:** High-visibility digital readout in 24-hour format.
* **Dynamic Weather:** Real-time temperature and status updates based on your actual hardware location.
* **Game of Life (GOL):** An interactive Cellular Automata simulation that runs on your desktop. 
    * **Interact:** Click and drag on the grid to seed new life.
    * **Auto-Reset:** Automatically reboots after 2,000 generations to prevent stagnation.
* **NASA Mission Feed:** Pulls the latest NASA Image of the Day along with its official title.
* **Language Quote of the Hour:** Fetches a German quote every hour and provides a synchronized English translation for language learners.

---

## Privacy & Portability (Zero-Config)

Unlike many widgets, Kontrollzentrum is designed to be shared and moved between machines without any code changes:
* **No API Keys:** Uses public RSS-to-JSON and Open-Meteo endpoints.
* **Automatic Geolocation:** Uses the macOS Geolocation API to find your city.
* **Local Caching:** Uses localStorage to ensure API limits are respected and data remains in sync.

---

## Installation

1.  **Install Übersicht:** Ensure you have the Übersicht application installed on your Mac.
2.  **Create the Widget:**
    * Open your Übersicht Widgets folder.
    * Create a new folder named Kontrollzentrum.widget.
    * Create a file inside named index.coffee.
3.  **Paste the Code:** Copy the provided CoffeeScript into index.coffee and save.
4.  **Permissions:** When the widget loads, macOS will ask for Location Permissions. Select Allow to enable the weather features.

---

## Customization

You can manually adjust the simulation logic at the top of the afterRender section:

| Variable | Description |
| :--- | :--- |
| speed | Delay (ms) between steps (Lower = Faster simulation) |
| spawnChance | Density of the initial grid (0.1 = Dense, 0.9 = Sparse) |
| autoReboot | How many generations to run before a fresh reset |
| entity_size | The pixel size of each individual cell |

---

## Troubleshooting

* **White Box/Blank Screen:** This usually indicates a CoffeeScript syntax error or a network interruption during the initial boot. Check the Übersicht Debug menu and select Show Developer Tools to see the console for errors.
* **Localizing Stuck:** Ensure Location Services are enabled in System Settings > Privacy & Security for the Übersicht application.
* **Weather Error:** The weather feed requires an active internet connection to contact the Open-Meteo API.

---

*System Nominal. Prepared for Operation.*
