#!/bin/bash
while [ true ] ;do
used=`free -m |awk 'NR==3 {print $4}'`

if [ $used -le 1000 ] && [ $used -gt 800 ]; then
echo "Free memory is below 1000MB. Possible memory leak!!!" 
elif [ $used -gt 1000 ]; then
echo " Memory is good. You have" $used "MB available of free memory."
fi
sleep 5
done
