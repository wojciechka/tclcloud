package provide tclcloud 1.0

package require sha256
package require base64
package require TclOO
package require TclCurl

oo::class create tclcloud::connection {

	constructor {key s_key} {
		my variable debug
		my variable AWS_info
		my variable AWS_address
		my variable AWS_product
		my variable AWS_products
		my variable AWS_rest_products
		set debug 0
		dict set AWS_address emr default address elasticmapreduce.amazonaws.com
		dict set AWS_address s3 default address s3.amazonaws.com
		dict set AWS_address ses default address email.us-east-1.amazonaws.com
		dict set AWS_address rds default address rds.amazonaws.com
		dict set AWS_address as default address autoscaling.amazonaws.com
		dict set AWS_address sqs default address sqs.us-east-1.amazonaws.com
		dict set AWS_address cw default address monitoring.us-east-1.amazonaws.com
		dict set AWS_address elb default address elasticloadbalancing.amazonaws.com
		dict set AWS_address vpc default address ec2.amazonaws.com
		dict set AWS_address iam default address iam.amazonaws.com
		dict set AWS_address cfn default address cloudformation.us-east-1.amazonaws.com
		dict set AWS_address cfn us-east-1 address cloudformation.us-east-1.amazonaws.com
		dict set AWS_address cfn us-west-1 address cloudformation.us-west-1.amazonaws.com
		dict set AWS_address cfn eu-west-1 address cloudformation.eu-west-1.amazonaws.com
		dict set AWS_address cfn ap-southeast-1 address cloudformation.ap-southeast-1.amazonaws.com
		dict set AWS_address cfn ap-northeast-1 address cloudformation.ap-northeast-1.amazonaws.com
		dict set AWS_address sdb default address sdb.amazonaws.com
		dict set AWS_address r53 default address r53.amazonaws.com
		dict set AWS_address ebs default address elasticbeanstalk.us-east-1.amazonaws.com 
		dict set AWS_address sns default address sns.us-east-1.amazonaws.com
		dict set AWS_address sns us-east-1 address sns.us-east-1.amazonaws.com
		dict set AWS_address sns us-west-1 address sns.us-west-1.amazonaws.com
		dict set AWS_address sns eu-west-1 address sns.eu-west-1.amazonaws.com
		dict set AWS_address sns eu-west-1 address sns.eu-west-1.amazonaws.com
		dict set AWS_address sns ap-southeast-1 address sns.ap-southeast-1.amazonaws.com
		dict set AWS_address sns ap-northeast-1 address sns.ap-northeast-1.amazonaws.com
		dict set AWS_address ec2 default address ec2.amazonaws.com
		dict set AWS_address ec2 us-east-1 address ec2.us-east-1.amazonaws.com
		dict set AWS_address ec2 us-west-1 address ec2.us-west-1.amazonaws.com
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

		dict set AWS_info a_key $key
		dict set AWS_info secret_key $s_key
	}
	method Output {msg} {
		my variable debug
		if {$debug == 1} {
			puts "\n-> [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] $msg"
		}
	}
	method Encode_url {orig} {
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
	method Sign_string {string_to_sign} {
		my variable AWS_info
		set signed [::sha2::hmac  [dict get $AWS_info secret_key] $string_to_sign]
		set signed [binary format H* $signed]
		set signed [string trim [::base64::encode $signed]]
		return $signed
	}
	method Get_version {product} {
		my variable AWS_product
		return [dict get [dict get [dict get $AWS_product $product] version] default]
	}
	method Get_address {product region} {
		my variable AWS_address
		if {"$region" == ""} {
			set region default
		}
		return [dict get [dict get [dict get $AWS_address $product] $region] address]
	}
	method Build_string_to_sign {aws_address querystring} {

		return "GET\n$aws_address\n/\n$querystring"

	}

	method Build_querystring {product action params version} {

		my variable AWS_info
		### according to the AWS api docs, the string to sign must be byte order by param name
		if {"$product" == "s3"} {
			upvar timestamp timestamp
			set timestamp [expr [clock seconds] + 60]
			set values(AWSAccessKeyId) [dict get $AWS_info a_key]
			set values(Expires) $timestamp
			lappend param_names AWSAccessKeyId Expires
		} elseif {"$product" != "ses"} {
			lappend param_names Action AWSAccessKeyId Timestamp SignatureMethod SignatureVersion Version
			set values(AWSAccessKeyId) [dict get $AWS_info a_key]
			set values(SignatureMethod) HmacSHA256
			set values(SignatureVersion) 2
			if {"$version" > ""} {
				set values(Version) $version
			} else {
				set values(Version) [my Get_version $product]
			}
			set values(Timestamp) [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%SZ"]
		} else {
			lappend param_names Action
		}
		set values(Action) $action
		foreach {key value} $params {
			if {[lsearch $param_names $key] > -1} {
				error "build_string_to_sign error: the parameter name $key is already defined"
			} elseif {"$key" == ""} {
				continue
			}
			lappend param_names $key
			set values($key) $value
		}
		set querystring ""
		foreach key [lsort $param_names] {
			set querystring "$querystring&$key=[my Encode_url $values($key)]"
		}
		set querystring [string range $querystring 1 end]
		return $querystring
	}
	method HttpCallback {token} {
	    upvar #0 $token state
	}
	method Build_url {product address querystring signature action} {
		if {"$product" == "ses"} {
			return "https://$address/?$querystring"
		} elseif {"$product" == "r53"} {
			return "https://$address/$action"
		} else {
			return "https://$address/?$querystring&Signature=$signature"
		}
	}
	method Perform_query {url header} {
		variable debug
		set tok [curl::init]
		$tok configure -url $url -httpheader $header -errorbuffer err_buf -headervar head_buf -bodyvar body_buf -verbose 0
		$tok perform
		if {[$tok getinfo responsecode] != 200} {
			set debug 1
		}
		if {[$tok getinfo responsecode] != 200} {
			error $body_buf
		}
		$tok cleanup
		return $body_buf
	}
	method call_aws {product region action params {version ""}} {

		my variable AWS_products
		my variable AWS_info
		if {"$product" == ""} {
			error "call_aws error: product value is required"
		}
		set aws_address [my Get_address $product $region]
		set querystring [my Build_querystring $product $action $params $version]
		if {"$product" == "s3"} {
			set signature [my Sign_string "GET\n\n\n$timestamp\n\n/"]
			set header ""
		} elseif {"$product" == "r53"} {
			set date_header [clock format [clock seconds] -format "%a, %e %b %Y %H:%M:%S +0000"]
			lappend header "Date: $date_header"
			set signature [my Sign_string $date_header]
			set xamzn_header "AWS3-HTTPS AWSAccessKeyId=[dict get $AWS_info a_key],Algorithm=HmacSHA256,Signature=$signature"
			lappend header "X-Amzn-Authorization: $xamzn_header"
		} elseif {"$product" == "ses"} {
			set date_header [clock format [clock seconds] -gmt 1 -format "%a, %e %b %Y %H:%M:%S +0000"]
			lappend header "Date: $date_header"
			set signature [my Sign_string $date_header]
			set xamzn_header "AWS3-HTTPS AWSAccessKeyId=[dict get $AWS_info a_key],Algorithm=HmacSHA256,Signature=$signature"
			lappend header "X-Amzn-Authorization: $xamzn_header"
		} else {
			set signature [my Encode_url [my Sign_string [my Build_string_to_sign $aws_address $querystring]]]
			set header ""
		}
		set url [my Build_url $product $aws_address $querystring $signature $action]
		set results [my Perform_query $url $header]
		return $results
	}

}

