# How to configure multiple interfaces on AWS ec2

### Quick notes on configuring multiple phoenix listeners on seperate network interfaces

AWS has a great feature that allows you to bind multiple virtual network interfaces (ENI) to a single instance.  This allows you do several things, like migrate an IP between two hosts.  I wanted to be able to run a dev server on another IP without having to fire up another instance.

The [ENI guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) is a good place to start.

Head over the AWS console and create a new ENI, ensure it is setup in the AZ you plan to use.  Once it is created you can then bind it to an instance by right clicking on the new ENI and assigning it to the instance.  

If you need to map DNS, next go create a new EIP (Elastic IP), right click to associate it to your instance and select the ENI you just created

EIPs are free as long as they are in use, so ensure you don't leave them sitting around unbound.

Now you shoule have 2 interfaces, and you can check like this:


```sh
$ ifconfig -a
eth0      Link encap:Ethernet  HWaddr 06:F0:45:89:00:01
          inet addr:10.1.0.34  Bcast:10.1.1.255  Mask:255.255.254.0
          inet6 addr: fe80::4f0:45ff:fe89:1/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:11229516 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10642366 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1340181266 (1.2 GiB)  TX bytes:4072465916 (3.7 GiB)

eth1      Link encap:Ethernet  HWaddr 06:D0:99:9B:B1:85
          inet addr:10.1.1.221  Bcast:10.1.1.255  Mask:255.255.254.0
          inet6 addr: fe80::4d0:99ff:fe9b:b185/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:1697 errors:0 dropped:0 overruns:0 frame:0
          TX packets:519 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:109796 (107.2 KiB)  TX bytes:1332985 (1.2 MiB)
```

Assuming you are using a VPC, you need to be sure you don't use your public IP's or EIP addresses.  AWS uses 1:1 NAT in VPC and your instance knows nothing about your public addresses.  

Next you need to take a look at your config/#{Mix.env}.exs  Below is my dev version (config/dev.exs), note the ip option 4 tuple, and that it is a tuple and not 10.1.1.221, but uses commas.  This ip option is what gets passed to ranch and will bind your IP address.  Ensure you change these for each env you need to adjust.

```elixir
config :reflux_eventbroker_react_phoenix_elixir, RefluxEventbrokerReactPhoenixElixir.Endpoint,
  http: [ip: {10,1,1,221},port: 8080],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch"]]
```

Fire up mix phoenix.server to ensure it works.

When you are all done and everything is working you can run 

```
[ec2-user@ip-10-1-0-34 ~]$ sudo service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]

```
