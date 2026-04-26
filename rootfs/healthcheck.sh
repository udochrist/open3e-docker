#! /bin/sh
#
# healthcheck script for open3e docker container
#
echo -n "running:"
RESULT=0


# Check if open3e process is running
ps aux |grep open3e |grep -q -v grep
if [ $? -ne 0 ]; then
    echo " -open3e"
    RESULT=1
else
    echo -n " +open3e"
fi

exit ${RESULT}
