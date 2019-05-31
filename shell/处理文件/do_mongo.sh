#! /bin/bash

#echo "input parameter :user_number + date(yyyyMMdd) + itemCode(88******)"
user_number="$1"
date="$2"
itemCode="$3"

if [ ! $user_number ]; then
  echo "user_number IS NULL"
fi
if [ ! $date ]; then
  echo "date IS NULL"
fi
if [ ! $itemCode ]; then
  echo "itemCode IS NULL"
fi

#echo "user_number:$user_number,date:$date,itemCode:$itemCode"

/home/mongo/mongo_server/bin/mongo  10.4.0.194:22101 --quiet <<EOF
db.getSiblingDB("admin").auth("root","root");
function hashCode(str){
  var h = 0, off = 0;
  var len = str.length
  for(var i = 0; i < len; i++){
    h = 31 * h + str.charCodeAt(off++);
    h=h%4294967296;
    if(h>2147483647) h=h-4294967296;
    if(h<-2147483648) h=h+4294967296;
  }
  return h;
}
var clomn="1"
var DrTypeList=["dr_cs","dr_ismp","dr_sms","dr_ps","dr_ocsps"];
var dbindex = Math.abs(hashCode(hex_md5("$user_number"+"$date"))&2147483647)%480;//分库数
var store = "Store"+dbindex;
var xdrdb = db.getSiblingDB(store);

for(var j=0;j<DrTypeList.length;j++){
        var sumCHARGE=0;
        if(DrTypeList[j]=="dr_ps"||DrTypeList[j]=="dr_ocsps"){
                clomn="20";
        }
        var table = Math.abs(hashCode(hex_md5("$user_number"))&2147483647) % clomn ;//分表数
        var collName = DrTypeList[j]+"_"+table+"_0_"+"$date";
        var count1 = xdrdb.getCollection(collName).count({"USER_NUMBER":"$user_number","ACC_ITEM_CODE1": "$itemCode","CHARGE1" : {\$ne:NumberLong(0)}})
        if(count1>0){
                print(store+"."+collName+".ACC_ITEM_CODE1:"+"$itemCode"+",count:"+count1)
                print($user_number+" "+$date+" "+$itemCode)
                var cursor = xdrdb.getCollection(collName).find({"USER_NUMBER":"$user_number","ACC_ITEM_CODE1": "$itemCode","CHARGE1" : {\$ne:NumberLong(0)}})
                while(cursor.hasNext()){
                        doc = cursor.next();
                        sumCHARGE+=doc.CHARGE1;
                        printjson(doc);
                }
                print("sumCharge1:"+sumCHARGE/10)
                break;
        }
        var count2 = xdrdb.getCollection(collName).count({"USER_NUMBER":"$user_number","ACC_ITEM_CODE2": "$itemCode","CHARGE2" : {\$ne:NumberLong(0)}})
        if(count2>0){
                print(store+"."+collName+".ACC_ITEM_CODE2:"+"$itemCode"+",count:"+count2)
                print($user_number+" "+$date+" "+$itemCode)
                var cursor = xdrdb.getCollection(collName).find({"USER_NUMBER":"$user_number","ACC_ITEM_CODE2": "$itemCode","CHARGE2" : {\$ne:NumberLong(0)}})
                while(cursor.hasNext()){
                        doc = cursor.next();
                        sumCHARGE+=doc.CHARGE2;
                        printjson(doc);
                }
                print("sumCharge2:"+sumCHARGE/10)
                break;
        }
        var count3 = xdrdb.getCollection(collName).count({"USER_NUMBER":"$user_number","ACC_ITEM_CODE3": "$itemCode","CHARGE3" : {\$ne:NumberLong(0)}})
        if(count3>0){
                print(store+"."+collName+".ACC_ITEM_CODE3:"+"$itemCode"+",count:"+count3)
                print($user_number+" "+$date+" "+$itemCode)
                var cursor = xdrdb.getCollection(collName).find({"USER_NUMBER":"$user_number","ACC_ITEM_CODE3": "$itemCode","CHARGE3" : {\$ne:NumberLong(0)}})
                while(cursor.hasNext()){
                        doc = cursor.next();
                        sumCHARGE+=doc.CHARGE3;
                        printjson(doc);
                }
                print("sumCharge3:"+sumCHARGE/10)
                break;
        }
        var count4 = xdrdb.getCollection(collName).count({"USER_NUMBER":"$user_number","ACC_ITEM_CODE4": "$itemCode","CHARGE4" : {\$ne:NumberLong(0)}})
        if(count4>0){
                print(store+"."+collName+".ACC_ITEM_CODE4:"+"$itemCode"+",count:"+count4)
                print($user_number+" "+$date+" "+$itemCode)
                var cursor = xdrdb.getCollection(collName).find({"USER_NUMBER":"$user_number","ACC_ITEM_CODE4": "$itemCode","CHARGE4" : {\$ne:NumberLong(0)}})
                while(cursor.hasNext()){
                        doc = cursor.next();
                        sumCHARGE+=doc.CHARGE4;
                        printjson(doc);
                }
                print("sumCharge4:"+sumCHARGE/10)
                break;
        }

        //var count = xdrdb.getCollection(collName).count({"USER_NUMBER":"$user_number"})
        //if(count>0){
        //        print(store+"."+collName+":"+count)
        //}
}
EOF
#echo "--end"