---
date: '2010-07-24 21:54:35'
layout: post
slug: simulating-a-low-bandwidth-link-with-openbsd-and-pf
status: publish
title: Simulating a Low Bandwidth Link with OpenBSD and pf
wordpress_id: '66'
categories:
- Embedded
---

Simulating application or device performance under limited network conditions is common, since it is important to know how everything works under real-life scenarios. At least for the software that I usually work on, the limiting factor is a customer's network connection. Nice tools exist to limit throughput, add latency, drop random packets, but for most of my development, I just want a quick sanity check to see performance under reduced bandwidth. While Linux and Windows have awesome tools for limiting bandwidth to locally run applications, I need to do it for embedded devices that either can't run the software or leave you wondering whether the addition processing for traffic shaping is affecting the results. Luckily, OpenBSD's pf can be set up in almost no time at all as a transparent bridge to shape network traffic. In fact, if you don't already have OpenBSD installed on a spare PC, installing it takes nearly no time since the defaults are pretty good.

Here's my setup:

![](http://troodon-software.com/wp-content/uploads/2010/07/072510_0154_Simulatinga1.png)

The OpenBSD box is setup as a transparent bridge, so from the device's perspective, it looks just like a cable connecting it to the DSL router. Since I only had two Ethernet ports on the OpenBSD box, I had to do all configuration through the console, but that's not a big deal. I've marked the LAN interface names as that will become important shortly. The first step is to setup the transparent bridge.

If you haven't already, create the /etc/network.* files for your network interfaces. Mine are axe0 and fxp0 and their hostname files just contain the word "up":

/etc/hostname.axe0:

    
    <code>up
    </code>


/etc/hostname.fxp0:

    
    <code>up
    </code>


Then create a hostname file for configuring the bridge:

/etc/hostname.bridge0

    
    <code>add fxp0 add axe0 up
    </code>


Again, not much rocket science here. The hostname files just get read by the netstart script on boot to pass the right options to ifconfig. At this point, run the netstart script manually to create the bridge.

    
    <code>sh /etc/netstart
    </code>


The OpenBSD box should pass traffic from the device to the server and back. In my current scenario, the server was somewhere on the Internet. I had been using an ADSL connection to the Internet, but my client reported that the users of the application would often have substantially less bandwidth than even my ADSL connection. Since the device also has some functionality that required Internet access, but was not used during the testing, I did not want to slow it down. Here's my /etc/pf.conf:

    
    <code>inetside_if = fxp0
    deviceside_if = axe0
    server_ip = 66.92.159.12
    
    altq on $deviceside_if cbq bandwidth 1.5Mb queue { std_in, sim_in }
    altq on $inetside_if cbq bandwidth 300Kb queue { std_out, sim_out }
    
    queue std_out bandwidth 200Kb cbq(default, borrow)
    queue sim_out bandwidth 100Kb cbq
    queue std_in bandwidth 1Mb cbq(default, borrow)
    queue sim_in bandwidth 500Kb cbq
    
    pass on $inetside_if all
    pass on $deviceside_if all
    
    pass in on $deviceside_if proto tcp from any to $server_ip queue sim_in
    pass out on $inetside_if proto tcp from any to $server_ip queue sim_out
    </code>


After defining some convenience variables at the top, the first thing that needs to be done is to enable the queuing feature, altq, on both interfaces. Altq only supports queuing on egress packets, so the way to read the lines is that there's a 1.5Mbps pipe going to the device and a 300Kbps pipe going to the Internet. Both pipes contain two queues: one for standard traffic and the other for the simulated slow connection. The next lines define the queues. I used constant bandwidth queues (cbq), but there are many choices here. In both cases, the sim queues have reduced bandwidth. The standard queues have the borrow option to indicates to pf that it can borrow bandwidth from other queues if they are not being used. The final section contains the pf rules for traffic. Unlike a firewall configuration, we simply pass all traffic. The last two lines are the rules for directing traffic going to or from the specified server through the sim queues.  These look really weird, but make sense if you remember that pf is a stateful packet filter. The state gets created when the TCP connection gets made. This is from the device since it is the device that makes the initial connection to the server. Since the OpenBSD box is a bridge, pf sees each packet on both interfaces. Therefore, the "pass in on $deviceside_if" line causes a state to be created when the connection is made as seen from the $deviceside_if interface. That state marks the packets for routing through the sim_in queue. Since altq queues on egress, that means that packets returning from the server will get queued. Packets going to the server pass without delay. The second line is to limit the bandwidth on those packets. As packets flow through the $inetside_if to the server, they'll trigger state creation for this rule and cause to sim_out queue to be used.

To update pf's ruleset, just run pf –f /etc/pf.conf. Now, what are the results of this configuration? I connected a PC to the OpenBSD box to get results that I could post. If you were wondering about the server_ip, that's not from my client, but from the Washington, DC Speedtest.net server near me. Here's how my normal ADSL connection performs (pf queuing disabled):

![](http://troodon-software.com/wp-content/uploads/2010/07/072510_0154_Simulatinga2.png)

Using the above pf script, here's the result:

![](http://troodon-software.com/wp-content/uploads/2010/07/072510_0154_Simulatinga3.png)

As you can see, bandwidth is limited to about 500Kbps down and 100Kbps up. The ping time looks like it was unaffected, but I doubt that Speedtest.net is a reliable indicator of latency especially under saturation conditions. The default queue sizes in pf seem long enough that a test should show their effect, but that can be tuned in pf as well. If latency is important to you, you may want to calculate the queuing delay in pf and adjust queue lengths accordingly.

Here's another test run, but to another Speedtest.net server to demonstrate how the std_in and std_out queues work:

![](http://troodon-software.com/wp-content/uploads/2010/07/072510_0154_Simulatinga4.png)

The download side nearly matches what was seen to the Washington, DC server without traffic shaping. The upload speed is degraded probably due to the 300Kbps cap in pf.conf on all upstream traffic.

Now, a note of warning on this configuration: it is simplistic. The pf filter offers a lot of functionality for more complex or rigorous scenarios, and that's part of what makes using pf so cool. This is, however, a good place to start for limited bandwidth test scenarios, and it is quick to setup if you have an old PC on hand.
