#!/bin/sh
###########################
# Created: 21-June-2023   #
# Modified: 16-July-2023  #
# Author: Dalwinder Singh #
###########################

# This code setup the log file.
# It has multiple stages to log information for debugging purposes.

SCRIPT_LOG=$1
touch $SCRIPT_LOG

function SCRIPTENTRY(){
 timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
 echo "[$timeAndDate] [DEBUG]  >>Metapipe Start" >> $SCRIPT_LOG
}

function SCRIPTEXIT(){
 script_name="${script_name%.*}"
 timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
 echo "[$timeAndDate] [DEBUG]  >>Metapipe Finish" >> $SCRIPT_LOG
}

function ENTRY(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
 echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $SCRIPT_LOG
}

function EXIT(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
 echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $SCRIPT_LOG
}


function INFO(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
    echo "[$timeAndDate] [INFO]   $msg" >> $SCRIPT_LOG
}

function DEBUG(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
 echo "[$timeAndDate] [DEBUG]  $msg" >> $SCRIPT_LOG
}

function ERROR(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date "+%Y-%m-%d %H:%M:%S"`
    echo "[$timeAndDate] [ERROR]  $msg" >> $SCRIPT_LOG
}

