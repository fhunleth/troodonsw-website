---
date: '2010-06-12 08:31:24'
layout: post
slug: hdmi-support-for-applications
status: publish
title: HDMI Support for Applications!
wordpress_id: '18'
categories:
- HDMI
---

Now that HDMI specifications support 3D video, 4K x 2K video resolutions, and 48bpp color depths, it is time for the HDMI specification authors to start focusing on how the HDMI cable can promote better application support on our televisions. CEC support is nice, and I always think that it's cool when my PS3 turns on the TV and switches input automatically, but through some updates to the specification, HDMI could do far better. Here's what I want: 

* The ability for HDMI devices to send alpha blended graphics to the TV to support notifications from video inputs besides the currently selected one
* Video data to be blended with OSD graphics at the TV. If video is coming from my set top box, I do not want that box to scale, blend, color convert, or do anything with the video before it reaches the TV. My TV should know best how to de-interlace, scale or do whatever needs to be done to produce the best quality picture on its display, so don't mess with it and just be able to add menu graphics.
* Multiple mixed audio streams. I like sound effects with onscreen menus and when I hit pause, but if the original movie audio is encoded in Dolby Digital Plus, don't force the set top box to decode the Dolby Digital Plus and mix in the sound effects. Let my receiver or TV do the mixing.
* Serious device input support. Sending simple remote control commands through CEC is a start, but the TV is the center of the experience and should be able to act more like a KVM.

The TV is more than just a display device. Unless someone makes an all-in-one TV like several companies have done with smart phones (won't happen), TV users will always have to deal with multiple devices. Here's my wish for upgrades.

## Video

First, HDMI needs to support the transport of video and graphics separately. The following is representative of the current situation inside the main system-on-a-chips (SoCs) found inside set top boxes and TVs:

![](/assets/old/061410_1547_HDMISupport11.png)

Basically, the video processing hardware supports several graphics surfaces called planes. Depending on the SoC, the planes can be universal or special purpose. For example, the OSD Plane, which is used for menu graphics and overlays, is usually optimized for the RGB colorspace and supports an alpha channel. Video planes do not support alpha channels since video is opaque. Video planes also operate in the YCbCr colorspace and may support subsampled chrominance channels (don't worry if you don't know what this is. The important part is that video requires different handling from UI graphics). The SoC may support other planes to simplify the implementation of subtitles or support a second video decode or to support a hardware cursor. These video planes feed into a component called the Mixer. Between the planes and the mixer, data from each source gets converted to a common colorspace and bit depth, and then gets alpha blended together and sent to the Output block. Obviously, for the highest video quality, you want the minimum number of manipulations between the Video Decoder to the Output. It would really be bad if the decoded video were converted from YCbCr to RGB to be mixed with the OSD Plane and then converted back to YCbCr for output over HDMI. These transforms are not lossless due to numerical imprecision. Luckily, though, any set top box architect would be crazy to do this (actually there are even more reasons why not to do this.)

For the new case, call it multiplexed HDMI, the individual video and graphics planes get sent over HDMI individually where they get mixed on the TV:

![](/assets/old/061410_1547_HDMISupport21.png)

Prior to the higher HDMI 1.3 speeds becoming commonplace, it would seem like the bandwidth between the HDMI transmitter and receiver would be impossibly high. However, here's some math:

1. Main video running at 1080p 60Hz (CEA 861 VIC 16). This is a pixel clock of 148.5MHz. YCbCr and 4:2:2 transfer result in 148.5MHz * 16bits/pixel = 2.36Gbps
2. OSD plane running at 720p 60Hz with alpha information. 720p runs with a pixel clock of 74.25MHz without alpha. I would assume that encoding the OSD as YCbCr, 4:2:2, and an alpha channel is easier to implement than straight 32bits of RGBA, but given that HDMI does support wider than 24bpp formats for deep color and this is a worse case, let's assume 32bpp. That results in 74.25MHz * 32bits/pixel = 2.38Gbps
3. The subtitle plane, if even still relevant in the age of Blu-ray, probably is in the noise in the calculation. It may even be interesting to output two OSD planes, but that seems excessive for now.
4. Secondary video. The question here is if set top boxes have the option of using the display to scale and mix their video data, then do they even bother implementing scaling hardware locally to minimize bandwidth use for this plane. Assume that this is another 1080p 60Hz stream producing 2.36Gbps of data.
5. Audio still needs some bandwidth, but even 16 bit 7.1 LPCM audio @ 48KHz is only 6.144Mbps.


All in, the cable needs to carry about 7Gbps of data and this is within the capability of the current HDMI specifications (10.2Gbps max.) Smart set top boxes can make tradeoffs with their bandwidth to support higher resolution OSD planes or higher quality video.

To the HDMI specification writers: while you're adding a multiplexing capability to HDMI, figure out a way that HDCP doesn't have to be applied to everything. Sure, you're forced to protect content, but do OSD planes really need HDCP? It would be nice if an AV receiver could just forward HDMI video streams straight through from input to output without having to deal with any HDCP negotiations, etc. If the AV receiver wants to add on an onscreen UI, which could be nice, it could just send down OSD plane information to the TV, unencrypted, since who really cares about content protection of this UI.


## Audio


Compared to video, audio seems trivial to multiplex over an HDMI cable since it occupies so little bandwidth. Bandwidth is, of course, not the only issue, but other issues such as synchronization and sample rate conversion are solved problems. The HDMI specification would need additions to identify audio streams as such for the main video, UI and menus, and secondary menu. Once it does this, the TV or receiver has full control over the mixing levels of audio. Set top boxes could send a movie's audio totally uncompressed and still offer sound effects. To the purists who could care less about sound effects, feel free to globally turn them off at your receiver in this new system. They show up in the requirements for many set top boxes due to their ubiquity in nearly every other consumer electronics product, and it is getting embarrassing that so many set top boxes only generate sound effects when outputting stereo. The reason for this is that under the current system a set top box would need to decode your Dolby Digital or DTS source audio and mix in the sound effects. This sounds easy, but passing through Dolby Digital and DTS saves license fees and a sometimes lengthy certification process. Mixing audio is also not supported well in all set top box SoCs, and while this isn't a great excuse, it seems like a lot of effort to fix for a problem that architecturally is better solved at the AV receiver or TV.


## Input Support


The key to tying this system together is to finally fix the TV input situation. For a TV to truly support multiple applications where the applications are instantiated in separate hardware devices (game boxes, Blu-ray players, cable boxes, DVRs, Netflix boxes, etc.) the TV needs to work more like a PC or smart phone OS that lets one easily transition between applications while still letting some applications run in the background. This is more than just changing display inputs, but the input focus should also switch. Universal remotes certainly improve the situation, but fixing the problem at the TV can be the best solution. Here are some reasons:

1. No need for line-of-sight IR detectors, repeaters, etc. AV equipment can be hidden away. If IR is still needed, the TV's IR detector which is in an ideal location should be able to forward the proper codes.
2. Smart handling of focus by sending codes reliably to the equipment that is actively in use. The TV knows what's going on.
3. Reduction in redundant electronics. E.g. even though it's relatively cheap, why do I have to have a new remote plus all of the transceiver equipment on every box I purchase? Except for gaming, most of the buttons that I use for everything else are the same.
4. Enable support for pointer based remotes across equipment. Disclaimer: I used to work at Hillcrest Labs, so I'm firmly of the belief that some applications just work better with a pointer than up-down-left-right. Certainly buttons have their advantages in many situations, and I'd never want to completely give them up, but things like the Internet work way better with a pointer. I also believe that content selection is a lot nicer with a pointer, but I want the pointer to do the right thing whether or not the pointer-based app is running.
5. Support for notifications and widgets provided by equipment that is not the active fullscreen application. For example, if I'm playing a movie on my Blu-ray player, it would be nice if I could still get a sports score update if something extraordinary happens. User input intended for the notification app should properly go to the equipment showing the notification. All PCs and Macs can properly do this. The TV should be able to as well.
6. Support for shared peripherals. For example, the best location for a webcam is almost certainly on the frame of the TV. Many game systems use webcams and certainly Skype and other video conferencing apps can use them as well. Why do I need multiple webcams of questionable style and color for my family room sitting on top of the TV or sitting in a cabinet and needing to be positioned every time? Other peripherals that would be nice to share are microphones and USB Flash card readers for photos.


Anyone familiar with CEC is probably thinking that the HDMI TVs already have a solution, and it does for the first two points. It would be nice if all equipment supported it, but CEC is flawed in that it is way too slow. The data bit transfer rate on CEC is a speedy 400bps and that doesn't include mandatory per message overhead. Pointing certainly won't work at this rate. It needs at least 100Hz * 3 bytes for dx, dy and buttons * 8 bits/byte = 2400bps for data. (This, by the way, is a low estimate of the bit rate for pointing, since it is nice to have more bandwidth to more easily meet latency margins.) Sharing video cameras, microphones and USB Flash card readers need much more bandwidth. The good news is that these devices require bit rates in the range of what is provided for Ethernet on the new HDMI Ethernet and Audio Return Channel (HEAC). The additional work is to define APIs for discovering, sharing, and communicating with these devices. I am sure that significant reuse of what was done for USB can also be done for the TV environment.


## Why Not Make an All-in-one TV


Mobile phones have done all-in-one devices so why not the TV. If you could make an all-in-one, then the above would be moot. This could be a huge blog topic, but here are some thoughts:


1. Cable and satellite providers always want you to use their set top boxes. They have a big incentive to keep their environment under their control and their content protected.
2. Game machines, so long as they exist, have absurd graphics and processing requirements that are very costly except for the business model of recouping cost through software.
3. People don't upgrade TVs nearly as frequently as cell phones. Cell phone companies have a much better business model for enticing people to get new phones. I'm sure that some cable company has thought about trying to replicate the cell phone model by subsidizing TVs to subscribers like they do set top boxes. The logistics of doing this seem costly, even though the cost of the TV may be similar to that of a smart phone.
4. DRM requirements for content would probably cause the TV to have significant restrictions on the ability to develop which would almost certainly cause some companies to want to build a specialized device for their application. (I've been there.)
5. Most people already have a cabinet or someplace to put a set top box peripheral already. Mobile phones certainly don't have this luxury.

Despite this, I can't wait to see GoogleTV. It may change the entire situation and make this whole article less relevant, but then again, I had high hopes for an Apple TV that was really a TV and not just a set top box.


## Summary


Architecturally, the TV is in the convenient place to support a unified application environment from peripheral devices such as set top boxes, Blu-ray players, and movie streaming devices, but it needs help. HDMI has the bandwidth to support such an environment and extensions to HDMI to support video, audio, and input multiplexing are one way of doing this. Now that HDMI has support for seriously high quality video and audio, support for improving the application environment should be the next priority for the specification.
