---
date: '2010-06-20 15:27:13'
layout: post
slug: euclidean-bipartite-matching-multi-touch-and-android
status: publish
title: Euclidean Bipartite Matching, Multi-touch, and Android
wordpress_id: '34'
categories:
- Algorithms
- Android
---

While reading through the input code on Android for a totally different task, I came across the most unexpected comment:

	// Note that this algorithm is far from perfect.  Ideally
	// we should do something like the one described at
	// http://portal.acm.org/citation.cfm?id=997856

If you've ever worked with the Android input system code, you've
probably dealt with several files that have become feature dumping
grounds, victims of code optimization passes, and that have a lack of
comments. Even though that comment was in code that clearly did not
impact my work at all, I had to follow the link: "A Near-Linear
Constant-Factor Approximation for Euclidean Bipartite Matching?" (1) Wow, this was not a graph theory problem that I had expected in this code. Bipartite matching is just not the kind of code that you would expect in the critical path, but it turns out to be key to making multi-touch sensors work in a sane way. 


## The Problem


Here's the problem: When your fingers touch the multi-touch sensor, it reports each of the touch points to driver. The sensor doesn't know which finger you're using at each point, but it doesn't matter to it. It just reports back a list. Say it reports where you pressed your thumb as the first element and your index finger as the second element. A short time later, the sensor will want to report the new location of your fingers. Once again, it gets the press locations, but it doesn't know which finger you're using, so it may swap the locations from the previous report. E.g. now your index finger's location will be the first element and your thumb will be the second. Now imagine that the multi-touch sensor is big enough for all 10 fingers. If you're dragging objects around on the screen and some code doesn't keep the order of the touch locations consistent, the objects that you're dragging are going to be popping around all over the place.

The graph theory name for this problem is the Euclidean bipartite matching problem. It's a matching problem, since the algorithm needs to match a touch location in the previous report to a touch location in the current report. Each touch location is a vertex and the match from the previous report to the current one is an edge. It is bipartite, since vertices fall into two groups, those in the previous report and those in the current one, and there can only be edges between the two groups. (This seems obvious unless the sensor is broken and reports two press locations for one finger. I guess you could also have a particularly nasty growth on the tip of a finger.) Finally, the problem is Euclidean since the metric being used to identify which presses belong to the same finger is those with minimum distance apart on a flat (Euclidean) surface. Taken together, the problem is what matching between the previous and current reports produces a set of edges with the minimum total distance over all possible matchings.

Here's an example input. The blue circles represent touch points from the previous report and the red circles are from the current report.

![](/assets/old/062010_1927_EuclideanBi1.png)

The output of the algorithm is the best matching. In this case, it's pretty easy to see that someone is dragging the five fingers on their right hand down and to the right.

![](/assets/old/062010_1927_EuclideanBi2.png)


## Android's Solution (circa June 2010)


The source code for the solution in Android can be found in the InputDevice class in the updatePointerIdentifiers() function. See [here](http://android.git.kernel.org/?p=platform/frameworks/base.git;a=blob;f=services/java/com/android/server/InputDevice.java;h=6f207e0ff8b93cee4f8c8945464b53541130f3ed;hb=HEAD). The source code is a little much to be reproduced here and due to a couple optimizations to avoid memory allocations, it isn't exactly pretty. Don't worry about it though, since the core of it does the following:
	
1. For each point in the previous report, calculate the distance between it and every point in the current report. Choose the pair that has the shortest distance.
2. Since some points in the previous report may map to the same point in the current one (a conflict), do the following:
    1. For each conflict, calculate the distance between each source point in the previous report and the destination.
    2. Take the one with the longest distance, toss the matching, and find the new best matching that includes that source point in the previous record and a point with no matches in the current report.
    3. Repeat until no conflicts.

Here's what the state looks like for our example input after step 1:

![](/assets/old/062010_1927_EuclideanBi3.png)

If we assume that these points are from fingers on a right hand, then the little and ring fingers from the previous report got mapped to the same point. That's were step 2 comes in. It looks at each edge in the conflict and then finds the next best match for the previous report vertex that's on the longest edge. (Don't ask me why the longest edge was picked. I'd probably start with the second shortest edge, but that's more code and it doesn't matter in this example anyway.) Here's the result:

![](/assets/old/062010_1927_EuclideanBi4.png)

Ouch, my fingers can't do that. Oh well, the comment said that the algorithm was far from perfect, so we're ok. In practice, I would suspect that the sample rate is high enough that the distance between true corresponding points between each report is actually very small and this situation would not occur for most movement.

Now, if we did have the perfect algorithm that minimized the total distance, would it do better for those fingers? That's for another post.


## Near-linear constant-factor approximation for Euclidean Bipartite Matching


Finally, back to the paper referred to by the code comment that started it all. What is incredible (to me at least) is that while the straightforward way of solving a bipartite matching problem is to use an O(|E||V|) algorithm called the Hungarian algorithm, you can do so much better if you restrict yourself to the 2D Euclidean case. The paper gives an approximation algorithm that is almost linear time. That was 2004. Just from reading their algorithm, it feels like it is overkill for the small number of vertices encountered in the multi-touch sensor case, but it is certainly interesting and surprising how much can be inferred from what seem to be so few comparisons.


## References





	
  1. Pankaj Agarwal , Kasturi Varadarajan, A near-linear constant-factor approximation for euclidean bipartite matching?, Proceedings of the twentieth annual symposium on Computational geometry, June 08-11, 2004, Brooklyn, New York, USA


