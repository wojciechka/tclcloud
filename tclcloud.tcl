# -------------------------------------------------------------------------
# See the file "license.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------

package provide tclcloud 1.3

package require Tcl 8.5
package require sha256
package require base64
package require uri
package require http
package require tls


namespace eval tclcloud {

	variable debug 0
	variable AWS_info
	variable AWS_address
	variable AWS_product
	variable AWS_products
	variable AWS_rest_products
	variable AWS_protocol https

	dict set AWS_address emr default address elasticmapreduce.amazonaws.com
	dict set AWS_address emr us-east-1 address elasticmapreduce.us-east-1.amazonaws.com
	dict set AWS_address emr us-west-1 address elasticmapreduce.us-west-1.amazonaws.com
	dict set AWS_address emr us-west-2 address elasticmapreduce.us-west-2.amazonaws.com
	dict set AWS_address emr eu-west-1 address elasticmapreduce.eu-west-1.amazonaws.com
	dict set AWS_address emr ap-southeast-1 address elasticmapreduce.ap-southeast-1.amazonaws.com
	dict set AWS_address emr ap-northeast-1 address elasticmapreduce.ap-northeast-1.amazonaws.com
	dict set AWS_address s3 default address s3.amazonaws.com
	dict set AWS_address ses default address email.us-east-1.amazonaws.com
	dict set AWS_address ses us-east-1 address email.us-east-1.amazonaws.com
	dict set AWS_address rds default address rds.amazonaws.com
	dict set AWS_address rds us-east-1 address rds.us-east-1.amazonaws.com
	dict set AWS_address rds us-west-1 address rds.us-west-1.amazonaws.com
	dict set AWS_address rds us-west-2 address rds.us-west-2.amazonaws.com
	dict set AWS_address rds eu-west-1 address rds.eu-west-1.amazonaws.com
	dict set AWS_address rds ap-southeast-1 address rds.ap-southeast-1.amazonaws.com
	dict set AWS_address rds ap-northeast-1 address rds.ap-northeast-1.amazonaws.com
	dict set AWS_address as default address autoscaling.amazonaws.com
	dict set AWS_address as us-east-1 address autoscaling.us-east-1.amazonaws.com
	dict set AWS_address as us-west-1 address autoscaling.us-west-1.amazonaws.com
	dict set AWS_address as us-west-2 address autoscaling.us-west-2.amazonaws.com
	dict set AWS_address as eu-west-1 address autoscaling.eu-west-1.amazonaws.com
	dict set AWS_address as ap-southeast-1 address autoscaling.ap-southeast-1.amazonaws.com
	dict set AWS_address as ap-northeast-1 address autoscaling.ap-northeast-1.amazonaws.com
	dict set AWS_address sqs default address sqs.us-east-1.amazonaws.com
	dict set AWS_address sqs us-east-1 address sqs.us-east-1.amazonaws.com
	dict set AWS_address sqs us-west-1 address sqs.us-west-1.amazonaws.com
	dict set AWS_address sqs us-west-2 address sqs.us-west-2.amazonaws.com
	dict set AWS_address sqs eu-west-1 address sqs.eu-west-1.amazonaws.com
	dict set AWS_address sqs ap-southeast-1 address sqs.ap-southeast-1.amazonaws.com
	dict set AWS_address sqs ap-northeast-1 address sqs.ap-northeast-1.amazonaws.com
	dict set AWS_address cw default address monitoring.us-east-1.amazonaws.com
	dict set AWS_address cw us-east-1 address monitoring.us-east-1.amazonaws.com
	dict set AWS_address cw us-west-1 address monitoring.us-west-1.amazonaws.com
	dict set AWS_address cw us-west-2 address monitoring.us-west-2.amazonaws.com
	dict set AWS_address cw eu-west-1 address monitoring.eu-west-1.amazonaws.com
	dict set AWS_address cw ap-southeast-1 address monitoring.ap-southeast-1.amazonaws.com
	dict set AWS_address cw ap-northeast-1 address monitoring.ap-northeast-1.amazonaws.com
	dict set AWS_address elb default address elasticloadbalancing.amazonaws.com
	dict set AWS_address elb us-east-1 address elasticloadbalancing.us-east-1.amazonaws.com
	dict set AWS_address elb us-west-1 address elasticloadbalancing.us-west-1.amazonaws.com
	dict set AWS_address elb us-west-2 address elasticloadbalancing.us-west-2.amazonaws.com
	dict set AWS_address elb eu-west-1 address elasticloadbalancing.eu-west-1.amazonaws.com
	dict set AWS_address elb ap-southeast-1 address elasticloadbalancing.ap-southeast-1.amazonaws.com
	dict set AWS_address elb ap-northeast-1 address elasticloadbalancing.ap-northeast-1.amazonaws.com
	dict set AWS_address vpc default address ec2.amazonaws.com
	dict set AWS_address vpc us-east-1 address ec2.us-east-1.amazonaws.com
	dict set AWS_address vpc us-west-1 address ec2.us-west-1.amazonaws.com
	dict set AWS_address vpc us-west-2 address ec2.us-west-2.amazonaws.com
	dict set AWS_address vpc eu-west-1 address ec2.eu-west-1.amazonaws.com
	dict set AWS_address vpc ap-southeast-1 address ec2.ap-southeast-1.amazonaws.com
	dict set AWS_address vpc ap-northeast-1 address ec2.ap-northeast-1.amazonaws.com
	dict set AWS_address iam default address iam.amazonaws.com
	dict set AWS_address cfn default address cloudformation.us-east-1.amazonaws.com
	dict set AWS_address cfn us-east-1 address cloudformation.us-east-1.amazonaws.com
	dict set AWS_address cfn us-west-1 address cloudformation.us-west-1.amazonaws.com
	dict set AWS_address cfn us-west-2 address cloudformation.us-west-2.amazonaws.com
	dict set AWS_address cfn eu-west-1 address cloudformation.eu-west-1.amazonaws.com
	dict set AWS_address cfn ap-southeast-1 address cloudformation.ap-southeast-1.amazonaws.com
	dict set AWS_address cfn ap-northeast-1 address cloudformation.ap-northeast-1.amazonaws.com
	dict set AWS_address sdb default address sdb.amazonaws.com
	dict set AWS_address sdb us-east-1 address sdb.amazonaws.com
	dict set AWS_address sdb us-west-1 address sdb.us-west-1.amazonaws.com
	dict set AWS_address sdb us-west-2 address sdb.us-west-2.amazonaws.com
	dict set AWS_address sdb eu-west-1 address sdb.eu-west-1.amazonaws.com
	dict set AWS_address sdb ap-southeast-1 address sdb.ap-southeast-1.amazonaws.com
	dict set AWS_address sdb ap-northeast-1 address sdb.ap-northeast-1.amazonaws.com
	dict set AWS_address r53 default address r53.amazonaws.com
	dict set AWS_address ebs default address elasticbeanstalk.us-east-1.amazonaws.com 
	dict set AWS_address ebs us-east-1 address elasticbeanstalk.us-east-1.amazonaws.com 
	dict set AWS_address sns default address sns.us-east-1.amazonaws.com
	dict set AWS_address sns us-east-1 address sns.us-east-1.amazonaws.com
	dict set AWS_address sns us-west-1 address sns.us-west-1.amazonaws.com
	dict set AWS_address sns us-west-2 address sns.us-west-2.amazonaws.com
	dict set AWS_address sns eu-west-1 address sns.eu-west-1.amazonaws.com
	dict set AWS_address sns eu-west-1 address sns.eu-west-1.amazonaws.com
	dict set AWS_address sns ap-southeast-1 address sns.ap-southeast-1.amazonaws.com
	dict set AWS_address sns ap-northeast-1 address sns.ap-northeast-1.amazonaws.com
	dict set AWS_address ec2 default address ec2.amazonaws.com
	dict set AWS_address ec2 us-east-1 address ec2.us-east-1.amazonaws.com
	dict set AWS_address ec2 us-west-1 address ec2.us-west-1.amazonaws.com
	dict set AWS_address ec2 us-west-2 address ec2.us-west-2.amazonaws.com
	dict set AWS_address ec2 eu-west-1 address ec2.eu-west-1.amazonaws.com
	dict set AWS_address ec2 eu-west-1 address ec2.eu-west-1.amazonaws.com
	dict set AWS_address ec2 ap-southeast-1 address ec2.ap-southeast-1.amazonaws.com
	dict set AWS_address ec2 ap-northeast-1 address ec2.ap-northeast-1.amazonaws.com
	dict set AWS_product emr version default 2009-03-31
	dict set AWS_product ec2 version default 2011-07-15
	dict set AWS_product sns version default 2010-03-31
	dict set AWS_product cfn version default 2010-05-15
	dict set AWS_product as version default 2010-08-01
	dict set AWS_product rds version default 2010-07-28
	dict set AWS_product sqs version default 2009-02-01
	dict set AWS_product ses version default 2010-12-01
	dict set AWS_product cw version default 2010-08-01
	dict set AWS_product elb version default 2011-04-05
	dict set AWS_product vpc version default 2010-11-15
	dict set AWS_product iam version default 2010-05-08
	dict set AWS_product sdb version default 2009-04-15
	dict set AWS_product r53 version default 2010-10-01
	dict set AWS_product ebs version default 2010-12-01
	set AWS_products [list ec2 emr as rds sqs ses cw elb vpc iam ebs]
	set AWS_rest_products [list s3 cloudfront sdb r53]

	lappend supported_providers aws eucalyptus

        ::http::register https 443 ::tls::socket
}
proc tclcloud::configure {provider key s_key {endpoint {}}} {

	variable supported_providers
	if {[lsearch $supported_providers $provider] == -1} {
		error "error: $provider not of of the supported providers: $supported_providers"
	}

	variable AWS_address
	variable AWS_info
	variable AWS_protocol

	if {"$endpoint" ne ""} {
		set region [lindex $endpoint 0]
		set address [lindex $endpoint 1]
		set protocol [lindex $endpoint 2]
		dict set AWS_address ec2 $region address $address
		if {"$protocol" ne ""} {
			if {"$protocol" ne "http" && "$protocol" ne "https"} {
				error "error: protocol $protocol not supported. Must be either http or https"
			}
			set AWS_protocol $protocol
		}
	}
	dict set AWS_info a_key $key
	dict set AWS_info secret_key $s_key
}
proc tclcloud::Output {msg} {
	variable debug
	if {$debug == 1} {
		puts "\n-> [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] $msg"
	}
}
proc tclcloud::Encode_url {orig} {
    set res ""
    set re {[-a-zA-Z0-9.,_]}
    foreach ch [split $orig ""] {
	if {[regexp $re $ch]} {
	    append res $ch
	} else {
	    foreach uch [split [encoding convertto utf-8 $ch] ""] {
		append res "%"
		binary scan $uch H2 hex
		set hex [string toupper $hex]
		append res $hex
	    }
	}
    }
    return $res
}
proc tclcloud::Sign_string {string_to_sign} {
	variable AWS_info
	set signed [::sha2::hmac  [dict get $AWS_info secret_key] $string_to_sign]
	set signed [binary format H* $signed]
	set signed [string trim [::base64::encode $signed]]
	return $signed
}
proc tclcloud::Get_version {product} {
	variable AWS_product
	return [dict get [dict get [dict get $AWS_product $product] version] default]
}
proc tclcloud::Get_address {product region} {
	variable AWS_address
	if {"$region" eq ""} {
		set region default
	}
	if {![dict exist $AWS_address $product]} {
		error "error: the product $product is not a valid AWS product"
	}
	if {![dict exist [dict get $AWS_address $product] $region]} {
		error "error: the region $region is not a valid AWS region"
	}
	return [dict get [dict get [dict get $AWS_address $product] $region] address]
}
proc tclcloud::Build_string_to_sign {aws_address querystring} {

	variable AWS_protocol
	set uri_list [uri::split $AWS_protocol://$aws_address]
	set path ""
	set found -1
	foreach {key val} $uri_list {
		if {"$key" eq "path" && "$val" ne ""} {
			set path "/$val/"
			incr found
		} elseif {"$key" eq "host"} {
			set aws_address $val
			incr found
		}
		if {$found == 1} {
			break
		}
	}
	if {"$path" eq ""} {
		set path "/"
	}

	return "GET\n$aws_address\n$path\n$querystring"

}

proc tclcloud::Build_querystring {product action params version} {

	variable AWS_info
	### according to the AWS api docs, the string to sign must be byte order by param name
	if {"$product" eq "s3"} {
		upvar timestamp timestamp
		set timestamp [expr [clock seconds] + 60]
		set values(AWSAccessKeyId) [dict get $AWS_info a_key]
		set values(Expires) $timestamp
		lappend param_names AWSAccessKeyId Expires
	} elseif {"$product" ne "ses"} {
		lappend param_names Action AWSAccessKeyId Timestamp SignatureMethod SignatureVersion Version
		set values(AWSAccessKeyId) [dict get $AWS_info a_key]
		set values(SignatureMethod) HmacSHA256
		set values(SignatureVersion) 2
		if {"$version" ne ""} {
			set values(Version) $version
		} else {
			set values(Version) [tclcloud::Get_version $product]
		}
		set values(Timestamp) [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%S"]
	} else {
		lappend param_names Action
	}
	set values(Action) $action
	foreach {key value} $params {
		if {[lsearch $param_names $key] > -1} {
			error "error: the parameter name $key is already defined"
		} elseif {"$key" eq ""} {
			continue
		}
		lappend param_names $key
		set values($key) $value
	}
	set querystring ""
	foreach key [lsort $param_names] {
		set querystring "$querystring&$key=[tclcloud::Encode_url $values($key)]"
	}
	set querystring [string range $querystring 1 end]
	return $querystring
}
proc tclcloud::HttpCallback {token} {
    upvar #0 $token state
}
proc tclcloud::Build_url {product address querystring signature action} {
	variable AWS_protocol
	if {"$product" eq "ses"} {
		return "$AWS_protocol://$address/?$querystring"
	} elseif {"$product" eq "r53"} {
		return "$AWS_protocol://$address/$action"
	} else {
		return "$AWS_protocol://$address/?$querystring&Signature=$signature"
	}
}
proc tclcloud::Perform_query {url header} {
	variable debug
	set err_buf ""
	set head_buf ""
	set body_buf ""
	set err_msg ""
	catch {set token [::http::geturl $url -headers $header -timeout [expr 10 * 1000]]} error_code
	if {[string match "::http::*" $error_code] == 0} {
		if {[string match "error reading*software caused connection abort" $error_code]} {
			error "error: Cloud endpoint refused connection. Verfiy that address, port and protocol (http or https) are valid.\012url:\012\012$url"
		} else {
			error "error: $error_code\012url:\012\012$url"
		}
	}
	if {"[::http::status $token]" ne "ok" || [::http::ncode $token] != 200} {
		error "error: [::http::status $token] [::http::code $token] [::http::data $token]\012url:\012\012$url"
	} else {
		set body [::http::data $token]
	}

        if {[info exists token] == 1} {
                ::http::cleanup $token
        }
	if {$debug == 1} {
		puts "Return Body:\n$body"
	}
	return $body
}
proc tclcloud::call {product region action params {version ""}} {

	variable AWS_products
	variable AWS_info
	if {"$product" eq ""} {
		error "error: product value is required"
	}
	set aws_address [tclcloud::Get_address $product $region]
	set querystring [tclcloud::Build_querystring $product $action $params $version]
	if {"$product" eq "s3"} {
		set signature [tclcloud::Sign_string "GET\n\n\n$timestamp\n\n/"]
		set header ""
	} elseif {"$product" eq "r53"} {
		set date_header [clock format [clock seconds] -format "%a, %e %b %Y %H:%M:%S +0000"]
		lappend header "Date: $date_header"
		set signature [tclcloud::Sign_string $date_header]
		set xamzn_header "AWS3-HTTPS AWSAccessKeyId=[dict get $AWS_info a_key],Algorithm=HmacSHA256,Signature=$signature"
		lappend header "X-Amzn-Authorization: $xamzn_header"
	} elseif {"$product" eq "ses"} {
		set date_header [clock format [clock seconds] -gmt 1 -format "%a, %e %b %Y %H:%M:%S +0000"]
		lappend header "Date: $date_header"
		set signature [tclcloud::Sign_string $date_header]
		set xamzn_header "AWS3-HTTPS AWSAccessKeyId=[dict get $AWS_info a_key],Algorithm=HmacSHA256,Signature=$signature"
		lappend header "X-Amzn-Authorization: $xamzn_header"
	} else {
		set signature [tclcloud::Encode_url [tclcloud::Sign_string [tclcloud::Build_string_to_sign $aws_address $querystring]]]
		set date_header [clock format [clock seconds] -gmt 1 -format "%a, %e %b %Y %H:%M:%S +0000"]
		set header ""
		lappend header "Date: $date_header"
		lappend header "User-Agent: Tclcloud lib"
	}
	set url [tclcloud::Build_url $product $aws_address $querystring $signature $action]
	set results [tclcloud::Perform_query $url $header]
	return $results
}
