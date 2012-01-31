---
date: '2011-05-22 19:49:40'
layout: post
slug: more-reasons-against-using-raw-nand-flash
status: publish
title: More Reasons Against Using Raw NAND Flash
wordpress_id: '71'
categories:
- Embedded
---

When support for raw NAND Flash devices became commonplace on SoCs, I was looking forward to using it in new designs. No longer would I be limited to the small size, high cost or slow performance of NOR Flash. Don't get me wrong, I like the simplicity of NOR Flash, but the ability to store significant amounts of data on device is hard to pass up. A few years ago, I got my wish. Here's what happened:



	
  1. We found bugs in the wear leveling code. Imagine periodically losing data under the file system layer. Not fun.

	
  2. We had manufacturing challenges due to bad block handling. Just like with the previous NOR Flash devices, we programmed our NAND Flash devices before PCB assembly. NAND Flash devices have high bad block rates by design so this had to be taken into account by the device programmer. The logic we had available was to skip bad blocks. Skipping bad blocks is NOT a good heuristic when the proprietary Flash translation layer uses absolute offsets.

	
  3. We were warned a few times about supply chain problems with the NAND Flash. It's not fun being small when Apple orders a few billion NAND Flash devices.


Based on what I've heard, the first two issues have become less of a problem now. However, after losing so much time to the above in the past, I have avoided raw NAND Flash in new devices. In one design that I'm working on right now, we opted to use  a MicroSD card instead of a raw NAND Flash. The performance that we see from it is even better than using raw NAND. As a side note, Managed NAND was a totally legitimate option, but we passed on it for other reasons.

However, if you are still deciding whether to use raw NAND in your device and you don't have a history of using it, consider the following [white paper](http://focus.ti.com/lit/wp/spry164/spry164.pdf) that was just publish from TI. Here are the highlights:



	
  1. Raw NAND life cycles of about two years

	
  2. Need to handle bad blocks even at the beginning of the device

	
  3. Growing ECC requirements (16 bit, 24 bit or greater per 512 bytes)

	
  4. More Managed NAND recommendations


The white paper is also a good review of the available memory technologies. Highly recommended.




