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

function copy_changes {
  while read -r line || [[ -n "$line" ]]; do
    op=$(echo $line | cut -d" " -f1 )
    from=$(echo $line | cut -d" " -f2 )
    to=$(echo $line | cut -d" " -f3 )
    echo $op $from $to
  done < $1
}
