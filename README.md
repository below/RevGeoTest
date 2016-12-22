# RevGeoTest


## What am I ultimately trying to achive?

For an app, I need to reverse-geocode two different locations in one view. The locations arrive asynchronously, so I can not say if, when, or in which order they arrive.

## What is the problem?

When I implemented the call for the second location, `reverseGeocodeLocation` never called its completion block. 

## What did I try to fix the problem?

So I looked to the [CLGeocoder documentation](https://developer.apple.com/reference/corelocation/clgeocoder/1423621-reversegeocodelocation) and found this:

> After initiating a reverse-geocoding request, do not attempt to initiate another reverse- or forward-geocoding request.

I tried to remedy this by executing my `reverseGeocodeLocation` calls serially on a `DispatchQueue`, and using a `DispatchSemaphore` to block the queue execution until completion block is called. It looks like this (the code is in `getGeolocation` in `ViewController.swift`):

```swift
geocodingQueue.sync {
    let semaphore = DispatchSemaphore(value: 0);
    
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarkArray, error) in
        semaphore.signal()
        completionHandler(placemarkArray, error)
    })
    semaphore.wait()
}
```
## Why didn't that fix it?

If I call `semaphore.wait()`, the completion handler of `reverseGeocodeLocation` is never called. If I don't call `wait()`, the handler will be called, but of course that would not prevent me from executing another query on this queue — which is what I tried to prevent.

## What can you do?

Am I doing it wrong? The `DispatchQueue`/`DispatchSemaphore` works perfectly for other situations, so I assumed it works here. Or is there something else I overlooked?
