#### Tclcloud AWS SimpleDB Sample 
###  
###  This script creates a SimpleDB database (domain) and puts
###  sample data into the domain. It then pulls the data out
###  and removes the domain.
###
###  Make note of the xpath query used to count the number of 
###  attributes returned from the GetAttributes call and the 
###  use of xpath addressing to spin through the rows.
###
###  Reference:
###  http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/
###
###  Change the following lines to use your AWS Access and
###  Secret Key

set access_key MYACCESSKEY
set secret_key MYSECRETKEY

lappend ::auto_path ../
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

### create SimpleDB domain
puts "Creating the domain ... \n"
lappend args DomainName Tclcloud_test
set result [tclcloud::call sdb {} CreateDomain $args]
#puts $result

### add attributes

unset args
lappend args DomainName Tclcloud_test Item.1.ItemName Shirt1 Item.1.Attribute.1.Name Color Item.1.Attribute.1.Value Blue Item.1.Attribute.2.Name Size Item.1.Attribute.2.Value Med Item.1.Attribute.3.Name Price Item.1.Attribute.3.Value 0014.99 Item.1.Attribute.3.Replace true 
lappend args Item.2.ItemName Shirt2 Item.2.Attribute.1.Name Color Item.2.Attribute.1.Value Red Item.2.Attribute.2.Name Size Item.2.Attribute.2.Value Large Item.2.Attribute.3.Name Price Item.2.Attribute.3.Value 0019.99

after 1000
puts "\nInserting new items ...\n"
set result [tclcloud::call sdb {} BatchPutAttributes $args]
#puts $result


### list attributes

set item_name Shirt2
unset args
lappend args DomainName Tclcloud_test ItemName $item_name

after 1000
puts "Getting new items out of the domain ...\n"

set result [tclcloud::call sdb {} GetAttributes $args]
#puts $result
set result [strip_namespaces $result]
set count [get_xpath_value $result count(//Attribute)]

after 1000
puts "Listing the items ...\n"
for {set ii 1} {$ii <= $count} {incr ii} {
	set name [get_xpath_value $result //Attribute\[$ii\]/Name]
	set value [get_xpath_value $result //Attribute\[$ii\]/Value]
	puts "Item name = $item_name, Attribute $ii, Name = $name, Value = $value"
}

### delete the test domain
unset args
lappend args DomainName Tclcloud_test 

after 1000
puts "\nDeleting the domain ...\n"
set result [tclcloud::call sdb {} DeleteDomain $args]

puts "Done"
