#!/usr/bin/env bash

####  designed to be run as cron job 
####  The valid values for instance-state-code:
####  0 (pending), 16 (running), 32 (shutting-down), 48 (terminated), 64 (stopping), and 80 (stopped)


## Note Use this to filter only the InstanceId field from 'aws ec2 describe-instance' call
## aws ec2 describe-instances --filter Name=tag:Name,Values=MyAwesomeEc2Instance Name=instance-state-code,Values=16 | grep InstanceId | cut -d '"' -f4



function abort {
  EXIT_VAL="$?"
  echo "ERROR: Failed to execute '$BASH_COMMAND', line: ${BASH_LINENO[0]}"
  exit "$EXIT_VAL"
}


function usage {
  EXIT_VAL="${1:-0}"
  MESS="$2"
  [[ -z $MESS ]] || echo -e 1>&2 "$MESS\n"
  SCRIPT="$(basename $0)"


  cat<<-EOF



        Usage: $SCRIPT start|stop [OPTIONAL-FUNCTIONS]


           Usage:  $SCRIPT [start|stop]
           Start - starts all ec2 instances with tag 'Clapper:Yes'
           Stop  - stops all ec2 instances with tag 'Clapper:Yes'


           OPTIONAL-FUNCTIONS:
           getAllRunning                returns json of all running ec2-instances meta data in this account
           getAllStopped                returns json of all stopped ec2-instances meta data in this account
           listAllTagClapper            returns instance id of all ec2-instances with tag 'Clapper:Yes'
           listAllRunningTagClapper     returns instance ID's of all running ec2-instances tagged 'Clapper:Yes'
           listAllStoppedTagClapper     returns instance ID's of all stopped ec2-instances tagged 'Clapper:Yes'




        EOF

exit "$EXIT_VAL"

}

trap abort ERR


ENDPOINT_URL="https://ec2.us-iso-east-1....." # what ever your proxy uses

function getAllRunning {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem --filter Name=instance-state-code,Values=16
}


function getAllStopped {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem --filter Name=instance-state-code,Values=80
}


function getAllTagClapper {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem --filter Name=tag:Clapper,Values=Yes
}

function listAllTagClapper {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem \
	--filter Name=tag:Clapper,Values=Yes | grep InstanceId | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'
}


function listAllRunningTagClapper {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem \
	--filter Name=tag:Clapper,Values=Yes Name=instance-state-code,Values=16 | \
	grep InstanceId | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'


}

function listAllStoppedTagClapper {
	aws ec2 describe-instances --endpoint-url $ENDPOINT_URL --ca-bundle /etc/pki/tls/cert.pem \
	--filter Name=tag:Clapper,Values=Yes Name=instance-state-code,Values=80 | \
	grep InstanceId | awk '{print $2}' | sed 's/"//g' | sed 's/,//g'


}



function start {
	for i in $(listAllStoppedTagClapper) ; do \
		aws ec2 start-instances \
		--region us-east-1 \
		--endpoint https://ec2.us-iso-east-1.c2s.ic.gov \
		--instance-id $i ; \
		done
}


function stop {
	for i in $(listAllRunningTagClapper) ; do \
		aws ec2 stop-instances \
		--region us-east-1 \
		--endpoint https://ec2.us-iso-east-1.c2s.ic.gov \
		--instance-ids $i ; \
		done
}

### expands the args to call desired function
"$@"




