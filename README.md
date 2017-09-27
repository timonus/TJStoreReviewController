# TJStoreReviewController

`TJStoreReviewController` is a simple wrapper around `SKStoreReviewController` that provides the following.

- It's safe to call into on versions of iOS prior to 10.3.
- It had simple throttling based on how long the app has been installed.
- It has a helpful method for presenting store review UI in the App Store (for use when users manually tap a "Rate this app" button, for example), which defers the automatic prompt from showing.

## Usage

tl;dr -- Step #2 is the only necessary one!

1. On app launch, you can optionally call the `+appDidLaunch`. This doesn't trigger any prompt showing, but it marks the first time the app was launched to better inform `TJStoreReviewController` of when to show the prompt next. If you don't call `+appDidLaunch` the first time `+requestThrottledReview` will be treated as the initial app launch, which is often good enough.
2. In situations where you think it would be good to optimistically show a store prompt, call `+requestThrottledReview`. That's it!
3. If your app includes a dedicated button to allow users to review your app you can call `+reviewInAppStore:` passing your app's iTunes identifier. This shows the rating UI for your app in the App Store and also defers the next time `+ requestThrottledReview` will trigger the prompt to be shown.