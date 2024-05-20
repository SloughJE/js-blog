---
title: "Google Analytics Tracking in Plotly Dash App"
date: 2024-05-20 12:00:00 +0000
categories: [Plotly Dash, Google Analytics, Dashboard, Python]
tags: [Dash App, Google Analytics, Tutorial, Outbreak!]
---

# Add Google Analytics Tracking to Plotly Dash App

I had already built a Plotly Dash app and deployed it on an EC2 server. 

It's accessible at [https://outbreak-tracker.com/](https://outbreak-tracker.com/).

I wanted to add Google Analytics tracking to the app. 

Here's how I did it:

1. On your Google Analytics account, create a stream to get your Google Analytics tracking code, which will be in the format `GA-XXXXXXXX`.
2. In your Dash app's app.py file, add the following

```python
# add G analytics tracking
GA_MEASUREMENT_ID = 'G-XXXXXXXX'

app.index_string = f"""
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>My Dash App</title>
        <!-- Google Analytics -->
        <script async src="https://www.googletagmanager.com/gtag/js?id={GA_MEASUREMENT_ID}"></script>
        <script>
            window.dataLayer = window.dataLayer || [];
            function gtag(){{dataLayer.push(arguments);}}
            gtag('js', new Date());
            gtag('config', '{GA_MEASUREMENT_ID}');
        </script>
        <!-- End Google Analytics -->
        &#123;%metas%&#125;
        &#123;%favicon%&#125;
        &#123;%css%&#125;
    </head>
    <body>
        <div id="react-entry-point">
            &#123;%app_entry%&#125;
        </div>
        <footer>
            &#123;%config%&#125;
            &#123;%scripts%&#125;
            &#123;%renderer%&#125;
        </footer>
    </body>
</html>
"""
```
I added this above the start of the code for the `app.layout`. 

But what does this code do?

### Setup

`GA_MEASUREMENT_ID = 'G-XXXXXXXX'`: input your actual GA tracking code here.

`<title>My Dash App</title>` sets the title for the dash app. This appears in the web browser tab.


### Analytics Script Initialization

`<script async src="https://www.googletagmanager.com/gtag/js?id={GA_MEASUREMENT_ID}"></script>` asynchronously (async for faster loading of page) loads the Google Analytics script from the specified URL.

```html
<script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){{dataLayer.push(arguments);}}
    gtag('js', new Date());
    gtag('config', '{GA_MEASUREMENT_ID}');
</script>
```
This section contains JavaScript code for configuring Google Analytics.

`window.dataLayer = window.dataLayer || [];`: Initializes the dataLayer array if it doesn't already exist. It's like a container to store information that Google Analytics will use.

`function gtag(){{dataLayer.push(arguments);}}`: Defines a function named gtag, which puts information into the dataLayer array.

`gtag('js', new Date());`: This is a predefined command for Google Analytics to signify the loading of the JavaScript library, at the current date and time.

`gtag('config', '{GA_MEASUREMENT_ID}');`: Configures Google Analytics with your Measurement ID.


### HTML Template Placeholders
```html 
        {{%metas%}}
        {{%favicon%}}
        {{%css%}}
    </head>
    <body>
        <div id="react-entry-point">
            {{%app_entry%}}
        </div>
        <footer>
            {{%config%}}
            {{%scripts%}}
            {{%renderer%}}
        </footer>
    </body>
```

All these placeholders (`{{%css%}}`) and sections are essential for the Dash app to work properly:

`{{%metas%}}`: where Dash inserts meta tags, which can include information like the character set, viewport settings, and other metadata that helps with SEO and responsive design.

`{{%favicon%}}`: where Dash inserts the link to the app’s favicon, the small icon displayed in the browser tab.

`{{%css%}}`: where Dash inserts links to your CSS stylesheets, which are necessary for styling the app.

```html
<div id="react-entry-point">
    {{%app_entry%}}
</div>
```
`<div id="react-entry-point">`: This div is the main container for the Dash app’s content. The app’s React components will be rendered inside this div.

`{{%app_entry%}}`: where Dash inserts the actual content of the app.


```html
<footer>
    {{%config%}}
    {{%scripts%}}
    {{%renderer%}}
</footer>
```
`<footer>`: This contains placeholders for additional configurations and scripts necessary for the app to function.

`{{%config%}}`: where Dash inserts configuration settings.

`{{%scripts%}}`: where Dash inserts JavaScript files that the app depends on.

`{{%renderer%}}`: where Dash inserts the script that actually renders the Dash app.

---

Now we have a Google Analytics tracking in our Dash App. Browsing Privacy Diminished. 

Goal Achieved. 🥲

Perhaps I'll look into some alternatives in the future.

JS