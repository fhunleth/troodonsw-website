---
layout: post
title: "No Need to Optimize GPIO Access on Embedded Linux"
category: Embedded
tags: []
---
{% include JB/setup %}

It seems like bypassing the Linux /sys/class/gpio interface to access GPIOs is
becoming more common. The arguments in favor of this approach are normally
regarding speed. I'd argue that this is counterproductive and that there are
better tools on most embedded processors for accomplishing the same tasks.

For those unfamiliar with GPIO support in Linux, the Linux kernel provides a
file-based interface for letting user-land applications configure GPIO pins,
read and write their values, and block until a pin changes state. The interface
can be interacted with easily in the shell. When programming, it is customary to
wrap the file-based interface to hide the file opens, reads and writes. Many
libraries do this. The advantage to this interface is that working with GPIOs on
almost any embedded system is the same.

The problem with the Linux GPIO interface is that modifying the state of a pin
requires a call into the kernel and that can be surprisingly slow. Toggling the
GPIO to communicate with another device is called bitbanging, and since you're
operating at a low level, it's usually important to be able to toggle the GPIO
quickly. After all, if you're running on a 1 GHz ARM processor, you'd think that
it would be possible to toggle an GPIO at 100 MHz at least. That's not even
close to the case for many reasons, but the kernel call is certainly not
helpful. The common solution to this problem is to map the GPIO registers into a
user program's address space and write the GPIO registers directly. This, of
course, breaks all platform independence that the Linux GPIO interface tried to
offer and opens up the possibility of accidentally writing the wrong memory
address.

Almost all embedded platforms have tons of hardware accelerated interfaces so
that there is no need to bitbang if you can use it. The hardware accelerated
interfaces are often faster, require less CPU, have precise timing, and often
have a well-tested kernel device driver if you're not using bleeding edge
hardware. As an extreme case, imagine implementing a PWM output by bitbanging a
GPIO. Besides it being unreasonable for the Linux scheduler to provide
jitter-free scheduling of the code running the PWM, it would also use a lot of
the CPU. The PWM hardware in most embedded processors is close to fire and
forget, and it handles the toggling of the output pin in the background (well
into MHz rates). In the less extreme case of wanting to bitbang a SPI protocol
to another chip, hardware acceleration (and Linux drivers) can provide buffering
and precise timing. It may also be the case that the Linux kernel provides a
driver for the chip that you're communicating with, so communication with that
chip may be simple and high level.

If you have a low bitrate device or can't use hardware acceleration, you can
still consider using kernel drivers. For example, the Linux kernel provides
bitbanging versions of both the I2C and SPI drivers (i2c-gpio and spi-gpio).
These are useful when you run out of I2C and SPI hardware instances or if the
hardware accelerated drivers appear flakey. These are faster than what could be
implemented in userland and the kernel provides the same API to them as their
hardware accelerated versions. The Linux kernel also provides drivers for low
data rate interfaces such as buttons and LEDs. For example, the gpio-keys turns
GPIO toggling into key up and key down events that get sent through the Linux
input system. The leds-gpio driver lets you turn on and off GPIOs (usually
attached to LEDs) by name. The leds subsystem also has a trigger feature that
lets you blink LEDs within the kernel and tie the LED state to system events
like disk and network access.

If you've gotten this far and you still feel like you need to memory map the
GPIO registers to bitbang a protocol to another device, there are still better
options. Embedded processors like the TI AM335x series contain special purpose
microcontrollers (PRUs) precisely to offload custom hardware protocols from the
main CPU. These microcontrollers not only provide predictable timing, but
they're also very fast. If your processor does not contain an embedded
microcontroller, a common solution is to have a small external microcontroller
provide the interface to the hardware. The microcontroller has the advantage
that it is a much easier target for writing small hard real-time programs than
processors running Linux. Adding a small microcontroller also doesn't add much
to the total cost of a device.

To summarize, spending time optimizing Linux GPIO libraries at the cost of
platform independence is counterproductive since so many better ways of solving
slow GPIO access exist. Solutions like using device-specific kernel drivers have
advantages such as using hardware acceleration and providing a higher level
interface. Even when protocols are so custom that they are not supported by the
Linux kernel, a better alternative exists in using an internal or external
microcontroller to perform the hard real-time aspects of the protocol. Linux is
great at many things, but high speed and low jitter bitbanging is not one of
them.
