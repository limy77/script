#!/bin/bash

cat ./data.txt  | while read line
do
       sh one_test.sh  $line > temp
       grep  "ACC_ITEM_CODE"  temp 
       if [ $? -ne 0 ];then
                echo $line >> details22.txt
                sh one_test.sh  $line >> details22.txt
       else
               sh one_test.sh  $line >> details.txt
       fi
       rm temp
done