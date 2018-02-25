var node = document.getElementById('main');
var app = Elm.Main.embed(node);
// Note: if your Elm module is named "MyThing.Root" you
// would call "Elm.MyThing.Root.embed(node)" instead.

chrome.storage.local.get("trackingIds", function(items) {
    app.ports.loadTrackingIds.send(items['trackingIds']);
});

app.ports.updateStorage.subscribe(function(trackingIds) {
    chrome.storage.local.set({
        "trackingIds": trackingIds
    }, function() {
        console.log("message saved");
    });
});
