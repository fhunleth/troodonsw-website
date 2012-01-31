---
layout: post
title: "Using Git with the Dropbear SSH Client"
category: dropbear
tags: []
---
{% include JB/setup %}

Git works just fine with the Dropbear SSH client and public key authentication. It just needs some configuration. 
First, create the SSH public/private key pair:

	$ mkdir .ssh
	$ dropbearkey -t rsa -f .ssh/id_rsa

The next step is to get the public key portion:

	$ dropbearkey -f .ssh/id_rsa -y
	Public key portion is:
	ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgnAUy+r8Qo+jLftzkxboFiwkheo/zuiA0sNNaiHDOq9O
	GHCT1F5ROOkVk9+qsDsXHIgKycxzEv7uFl2ffHtbeiqLnWhuJowrrMEGYng+LAzdyWyNbOShLkkn18nD
	iEXBa2QPpiY/O3DPeJBM5kGeAmFkpsp1HjO/JWpPWn7nDVQ3afE= fhunleth@beaglebone
	Fingerprint: md5 2e:f3:c3:3a:3a:fa:93:00:a1:b7:b0:20:54:d5:67:40

Copy this to the git server.

The Dropbear client won't use the id_rsa key by default, so it needs to be told. The easy way to tell it every time is to wrap the call in a script. Create the file gitssh.sh with the following contents:

	#!/bin/sh
	ssh -i ~/.ssh/id_rsa $*

Just set the GIT_SSH environment variable to direct git to calling gitssh.sh:

	export GIT_SSH=~/gitssh.sh

Now try cloning a git repository.

