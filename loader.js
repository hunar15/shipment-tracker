var node = document.getElementById('main');
var app = Elm.Main.embed(node);
// Note: if your Elm module is named "MyThing.Root" you
// would call "Elm.MyThing.Root.embed(node)" instead.

chrome.storage.local.get("orders", function(items) {
    app.ports.loadTrackingIds.send(items['orders']);
});

app.ports.updateStorage.subscribe(function(orders) {
    chrome.storage.local.set({
        "orders": orders
    }, function() {
        console.log("message saved", orders);
    });
});
