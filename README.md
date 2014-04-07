DBKit
=====

Wrap Core Data with familiar DB architecture

Why would you want to do that? I don't like how Core Data is so invasive to my code. It is a tough architecture
to get your head around. I would rather encapsulate the whole thing elsewhere until I better understand it. Writing
DBKit is really helping with that. 

This project only support iOS currently. I have to figure out how to replace NSFetchedResultsController with
NSArrayController. That's fine because the NSController architecture isn't any easier to understand than Core Data.

What's the point? Just RTFM, you say. Well, I have read the manual, such as it is, and it's not so simple. There is
a tendency for smart people like programmers to embrace difficult puzzles as a way to demonstrate their intellectual
prowess. Just look at C++. As a reformed C++ programmer, I reject that idea. I find that the easier the framework
is to use, the more value I get out of it. Instead of spending time learning Apple's new paradigm for making database
queries or organizing data in a container, I can be working on adding functionality to my own software. In some cases,
like Core Data, it really isn't smart to try to reinvent the wheel, especially when Apple makes the roads. 

