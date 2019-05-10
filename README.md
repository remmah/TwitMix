# TwitMix

This app lets you browse the TWiT Network’s recent shows and bookmark your favorite episodes for playback.

Use the Browse tab to navigate TWiT’s recent shows. When you tap on an episode, it’s saved to the Mix tab for playback.

When you’re done selecting episodes, go to the Mix tab to see your saved episodes. Tap on any episode to play it. Swipe a saved episode to the left to delete it from the list.

## API Key

Note: This app relies on a private TWiT API key — located at `/TwitMix/Keys.plist` — to access show and episode data. These keys are not present in the public GitHub repo and for the app to work, you will have to supply your own API key. The `plist` file should be formatted as follows:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>app-id</key>
	<string>yourAppID</string>
	<key>app-key</key>
	<string>yourAppKey</string>
</dict>
</plist>
```
