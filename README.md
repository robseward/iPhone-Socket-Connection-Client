README
========
This app uses [CocoaAsyncSocket](http://code.google.com/p/cocoaasyncsocket/) to transmit touch data to a server. 

There's an example of a server written in Processing [here](https://github.com/robseward/iPhone-Socket-Connection-Server). 

And a blog post that includes a video [here](http://robseward.com/blog/2011/06/17/iphone-socket-connection-to-processing/).  
  
  
  
To Use:
-------
Load the app in XCode and at the top of TouchViewDrawController.m you'll see the line:

`#define kIpAddress @"192.168.1.103"`

Change the ip address address to that of your computer. Start up the server, start up the client, press the "reconnect" button, and you should see your touches translated to the computer screen. 