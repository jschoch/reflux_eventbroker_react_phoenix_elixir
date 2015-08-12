# How to configure multiple interfaces on AWS ec2

## Quick notes on configuring multiple phoenix listeners on seperate network interfaces

AWS has a great feature that allows you to bind multiple virtual network interfaces (ENI) to a single instance.  This allows you do several things, like migrate an IP between two hosts.  I wanted to be able to run a dev server on another IP without having to fire up another instance.

The [ENI guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) is a good place to start.

Head over the AWS console and create a new ENI, ensure it is setup in the AZ you plan to use.  Once it is created you can then bind it to an instance by right clicking on the new ENI and assigning it to the instance.  

If you need to map DNS, next go create a new EIP (Elastic IP), right click to associate it to your instance and select the ENI you just created

EIPs are free as long as they are in use, so ensure you don't leave them sitting around unbound.



When you are all done and everything is working you can run 

```
[ec2-user@ip-10-1-0-34 ~]$ sudo service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]

```
