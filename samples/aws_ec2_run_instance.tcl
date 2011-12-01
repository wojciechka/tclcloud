#### Tclcloud AWS EC2 Sample - run instances
###  
###  This script searches for a specific AWS AMI (machine image)
###  by name and architecture and runs an instance using the 
###  image id.
###
###  It then waits for the status to change to running
###  (networking assigned) and attempts to connect to 
###  the webserver after a boot delay.
###
###  NOTE: the http test assumes that the default security
###  group has port 80 open to at least the host running 
###  this script. 
###  
###  Reference:
###  http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/
###
###  Change the following lines to use your AWS Access and
###  Secret Key

set access_key MYACCESSKEY
set secret_key MYSECRETKEY

lappend auto_path ../
package require tclcloud 
package require tdom

proc strip_namespaces {xml} {
        set xmldoc [dom parse -simple $xml]
        set root [$xmldoc documentElement]
        set xml_no_ns [[$root removeAttribute xmlns] asXML]
        $root delete
        $xmldoc delete
	return $xml_no_ns
}

proc get_xpath_value {xml path} {
        set xmldoc [dom parse -simple $xml]
        set root [$xmldoc documentElement]
        set value [$root selectNodes string($path)]
        return $value
}

### define aws connection

set tclcloud::debug 0
set conn [tclcloud::configure aws $access_key $secret_key {}]

### find bitnami image id

lappend args Filter.1.Name architecture Filter.1.Value.1 x86_64 Filter.2.Name root-device-type Filter.2.Value.1 ebs Filter.3.Name name Filter.3.Value.1 {bitnami-wordpress-3.2.1-1-linux-x64-ubuntu-10.04-ebs}
set result [tclcloud::call ec2 {} DescribeImages $args]
unset args
#puts $result
set result [strip_namespaces $result]
set imageId [get_xpath_value $result //imageId]
puts "The image to start is $imageId" 


### start a bitnami wordpress instance

lappend args ImageId $imageId InstanceType t1.micro MinCount 1 MaxCount 1
set result [tclcloud::call ec2 {} RunInstances $args]
#puts $result
set result [strip_namespaces $result]
set instanceId [get_xpath_value $result //instanceId]
set az [get_xpath_value $result //placement/availabilityZone]
puts "The instance started is $instanceId in availability zone $az"

### monitor the instance until it comes up

set state pending
after 5000
while {"$state" == "pending"} {
	unset args
	lappend args InstanceId $instanceId 
	set result [tclcloud::call ec2 {} DescribeInstances $args]
	set result [strip_namespaces $result]
	#puts $result
	set state [get_xpath_value $result //instanceState/name]
	puts "state is $state"
	if {"$state" == "running"} {
		break
	} elseif {"$state" == "pending"} {
		after 10000
	} else {
		error "The instance $instanceId is not in a running or pending state. Current state is $state."
	}
}

### get addresses

set privateAddress [get_xpath_value $result //privateDnsName]
set publicAddress [get_xpath_value $result //dnsName]
puts "the private address is $privateAddress, public address is $publicAddress"
puts "we will wait for 60 seconds for the server to come up, then test the url ..."

### test the webserver, wait 60 seconds or so for services to come up

after 60000
package require http
set tok [::http::geturl "http://$publicAddress" -timeout 60000]
puts [::http::data $tok]
::http::cleanup $tok
