function header {
  echo "***********************************************************************"
  echo "****"
  echo "****"
  echo "****  Starting $(basename $1) at `date`"
  echo "****"
  echo "****"
  echo "***********************************************************************"
}

function footer {
  echo "***********************************************************************"
  echo "****"
  echo "****"
  echo "****  Finished $(basename $1) at `date`"
  echo "****"
  echo "****"
  echo "***********************************************************************"
}

###
# copy changes - allow simple substition of a  predefined local and remote directory
#                and a server name.
#
#                Note: The server name is assumed to be configured in .ssh/config and
#                      the username defined there. This will happen automatically if
#                      the server is created using the 00-create-server helper script.
#
#                      This function exists to try and uncouple the bash code from the
#                      actions required, making these scripts easier to re-use.

function copy_changes {
    CC_FILE=$1
    CC_LOCALPATH=$2
    CC_REMOTEPATH=$3
    CC_SERVER=$4

    while read -r line || [[ -n "$line" ]]; do
        op=$(echo $line | cut -d" " -f1 )
        from=$(echo $line | cut -d" " -f2 )
        from=$(echo $from | sed "s:LOCALDIR:$CC_LOCALPATH:")
        to=$(echo $line | cut -d" " -f3 )
        to=$(echo $to | sed "s:REMOTE:$CC_REMOTEPATH:")

        if [[ "$op" == "rsync" ]]; then
            echo "rsync -az $from $CC_SERVER:$to"
            rsync -az $from $CC_SERVER:$to
            rsync_result=$?
	    if [[ "$FAILFAST" ]] && [ $rsync_result -ne 0 ]; then
		echo "rsync failed with $rsync_result and FAILFAST is set - exiting"
                exit 1
	    fi 
        elif [[ "$op" == "scp" ]]; then
            echo "scp -r $from $CC_SERVER:$to"
            scp -r $from $CC_SERVER:$to
            scp_result=$?
            if [[ "$FAILFAST" ]] && [ $scp_result -ne 0 ]; then
                echo "scp failed with code $scp_result and FAILFAST is set - exiting"
                exit 1
            fi 
        else
            echo "You have asked to $op from $from to $to - I don't know how to do that"
        fi
    done < $CC_FILE
}

getVMIP() {
  VMIP=`rack servers instance get --name "$SRV_NAME" --fields=publicipv4 | cut -d $'\t' -f2`
}
