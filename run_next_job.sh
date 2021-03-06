#!/bin/bash

echoerr() { echo "$@" 1>&2; }


## read options
if [[ ! $@ ]]
then
    echoerr "No parameters specfied"
    echoerr "Use -h for help"
    exit 1
fi

while getopts 'j:i:n:hd' OPTION ; do
    case "$OPTION" in
	j)  JOBID=$OPTARG;;
	i)  INTERVAL=$OPTARG;;
	n)  NEXT=$OPTARG;;
	h)  echoerr "This script is used to check the slurm queue for a given JobID 
in a given interval and runs a given command, if the job is finished.

Usage: run_next_job.sh -j <JobId> -i <Interval> -n <next command>

       JobID: Comma separated list of Job IDs to check
    Interval: Time between each check. Use number and suffix (s,m,h,d)
              default:10m
next command: Command that should be run next (write in '' and set executable)" 
	    exit 0
	    ;;
	d)  echoerr "using debug mode"
	    DEBUG=1
	    ;;
	*)  echoerr "Unknown parameter"
	    echoerr "Use -h for help" 
	    exit 1
	    ;;
    esac
done


## check, if everything is specified
if [[ ! $JOBID ]]
then
    echoerr "ERROR: no Job IDs specified"
    exit 1
elif [[ ! $NEXT ]]
then
    echoerr "ERROR: no next command specified"
    exit 1
elif [[ ! $INTERVAL ]]
then
    echoerr "using default interval (10min)"
    INTERVAL=10m
fi


if [[ $DEBUG ]]
then
echoerr "Parameters:
JobIDs:   $JOBID
interval: $INTERVAL
next job: $NEXT"
fi

## main
RUNNING='1'

while [[ "$RUNNING" == "1" ]]
do
    HIT=$(squeue -h -j $JOBID)
    
    if [[ $DEBUG ]]
    then
	date
	echo $HIT
    fi
    
    if [[ ! $HIT ]]
    then
	RUNNING=0
    else
	sleep $INTERVAL
    fi
done

if [[ $RUNNING == 0 ]]
then
    date
    echo "all required jobs finished
running $NEXT"
    $NEXT
fi
