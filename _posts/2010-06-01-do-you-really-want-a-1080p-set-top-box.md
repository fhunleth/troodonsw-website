---
date: '2010-06-01 22:53:34'
layout: post
slug: do-you-really-want-a-1080p-set-top-box
status: publish
title: Do you really want a 1080p set top box?
wordpress_id: '12'
categories:
- HDMI
---

It seems like most TV set top boxes and media players these days support 1080p output through their HDMI ports. The ones that only support 1080i or 720p seem terribly out of date, but do you always want to run the output at 1080p? That seems best and certainly the marketing departments of many companies would lead you to believe this. Higher resolution is better, right? 

The answer is not always. What we really want is to see the content displayed at as high quality as possible. TV set top boxes and media players that output at 1080p may actually degrade content. Here's why: the diagram below shows a highly simplified view of what video goes through to get to your TV display.

![](http://troodon-software.com/wp-content/uploads/2010/06/061110_1355_Doyoureally11.png)

At the beginning, of course, is the source video from the production studio. Once the studio is satisfied with their content, they will master it to a DVD, Blu-ray, or other media suitable for transport to you. Most likely, the video data on this media is at a different resolution or frame rate than the original. For example, the video couple may be cropped to convert from an aspect ratio suitable for a movie theater to a TV format aspect ratio. If the media is a DVD or anything originally intended for a standard definition TV, then the content probably has been downscaled and interlaced to 480i. If the source content was originally a movie then its original 24 frames/second has been converted to about 30 frames/second (3:2 pulldown). These are horrible things to do to video, but they're not always under our control.

The Video Decoder step, which could be a DVD player or Netflix box, takes care of decoding that video and turning it into a format that can be sent to the TV. If you have HDMI, the display and the video decoder can negotiate the best video output mode to use. This certainly beats out what had to be done in the analog component days where we had to figure out what was best. In an ideal world, the display could dynamically switch resolution and interlacing at a physical level to conform to whatever the video decoder had. We had that to an extent with CRTs. LCD and Plasma displays cannot dynamically switch the dot pitch of their display or their update frequency, so they need to integrate hardware scalers and deinterlacers to convert video to their native resolution. Here's what happens:



	
  1. The video decoder decodes source content at 720p, for example.

	
  2. Since the Display is capable of 1080p, it requests that the video decoder send it content at 1080p.

	
  3. The video decoder scales the 720p content up to 1080p.

	
  4. The LCD panel on the display is not exactly 1080p since it was cheaper for the manufacturer to put in a different resolution panel, so the display rescales the content to match its panel.


Two scaling steps. Since each scaling step can degrade the video, that's not good. The HDMI signaling protocols actually allow the TV to request that video decoders output at the native resolution of their LCD displays. A manufacturer can enable this by modifying a data structure called the EDID. Sounds good, right? The video decoder handles the scaling to the native panel resolution so there's only one scaling step. This would be an improvement if the scalers and deinterlacers in most video decoder devices were actually any good. The current state of good video scalers and deinterlacers is that they are pricey. There is a reason that the pricier name brand TVs such as Sony and Samsung are better than other TVs and one of the reasons is that they have better scalers and deinterlacers. If you can't see the difference between TVs at the store, ask if you can see how standard definition (480i) content looks on different TVs. If you've grown accustomed to HD content, it will look terrible all around, but some TVs should definitely look better than others. The technology to do this is complex and heavily protected with patents. We, as consumers, don't mind paying hundreds of dollars for a TV, but try getting us to pay $100 for a DVD player or set top box. Getting back to the problem, the result is that consumer video decoders do not have good scaling and deinterlacing capability. The strategy, therefore, should be that the video decoder tries to avoid all scaling and deinterlacing and delegate that to the display. If you see the screen flicker black at the start of playing back a movie, that could be a good sign that the video decoder is actually switching output video modes to match the source content.

This isn't the end of the story, though. Remember 3:2 pulldown? If your source content is a 24 frames/second movie and you have a 120Hz display, then neither the video decoder nor the display need to perform 3:2 pulldown if the video decoder outputs 24 frames/second to the display. Awesome. This is yet another reason to avoid forcing video modes on video decoder devices.

Finally, if you're streaming content over the Internet, it's almost certainly not coming down as 1080p. Don't force the poor box to upscale it as well.
