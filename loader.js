var node = document.getElementById('main');
var app = Elm.Main.embed(node);
// Note: if your Elm module is named "MyThing.Root" you
// would call "Elm.MyThing.Root.embed(node)" instead.

chrome.storage.sync.get("trackingIds", function(items) {
    app.ports.loadTrackingIds.send(items['trackingIds']);
});
