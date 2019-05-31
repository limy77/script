#!/bin/bash
#如果参数个数小于4个，提示错误
if [ $# -ne 4 ]
then
        printf "Usage:\t${0##*/} -i confgFile <mode(1 servid,2 acctId)> [<servId/acctId>] \n"
        exit 0
fi
fileName=$2
Mode=$3
ID=$4
#配置文件信息
if [ ! -f "$fileName" ];then
	echo "config file not exist!"
	exit 0
fi
#==========================================================================================================================================
#查询用户账单表和账户账单表
if [ $Mode == 1 ];then
	TABLE="CRasResBill"
	VALUE="resource_id"
else
	TABLE="CRasAccBill"
	VALUE="pay_acct_id"
fi

for ipcfg in "aps1"  "aps2";
	do
	#echo "ipcfg="$ipcfg

	mdb_client_ext -i $fileName -m $ipcfg  > tmp << CLIENTEOF
		select * from $TABLE where $VALUE=$ID order by bill_id;
		exit;
CLIENTEOF


	if [ $Mode == 2 ];then
		mdb_client_ext -i  $fileName -m $ipcfg -d 0 >> tmp << CLIENTEOF
		select * from CRasResBill where $VALUE=$ID order by bill_id;
		exit;
CLIENTEOF
	fi


	BillIDall=`grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf $4" "}'`

	if [ -z "$BillIDall" ];then
		echo $ipcfg " has no records"
		rm tmp
		continue
	fi

	#echo "BillIDall="$BillIDall
	mdb_client_ext -i $fileName -m $ipcfg -d 0 > tmp << CLIENTEOF
	select * from $TABLE where $VALUE=$ID order by bill_id;
	exit;
CLIENTEOF

	#只保留数字的行，删除空格，然后根据','分隔数据
	if [ $Mode == 1 ];then
		printf " ----------------------------------------------------  CRASResBill  ----------------------------------------------------------\n"
		printf "%-15s%10s%15s%18s%15s%12s%15s%12s%14s\n" \
			"bill_id"   "pay_acct_id"  "resource_id"  "default_acct_id"  "begin_date"   "end_date"   "current_date"   "waif_flag"   "region_code"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%14d,%15d,%14d,%18d,%14d,%11d,%12d,%13d\n",$4,$3,$2,$5,$6,$7,$8,$9,$10}'
	else
		printf " ----------------------------------------------------  CRASAccBill  ----------------------------------------------------------\n"
		printf "%-15s%10s%15s%18s%15s%12s%15s%12s%14s\n" \
				"bill_id"   "acct_id"  "pay_acct_id"  "default_acct_id"  "begin_date"   "end_date"   "current_date"   "waif_flag"   "region_code"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%14d,%15d,%14d,%18d,%14d,%11d,%12d,%13d\n",$4,$2,$3,$5,$6,$7,$8,$9,$10}'
	fi


	if [ $Mode == 2 ];then
			mdb_client_ext -i $fileName -m $ipcfg  -d 0 > tmp << CLIENTEOF
			select * from CRasResBill where $VALUE=$ID order by bill_id;
			exit;
CLIENTEOF
			printf " \n\n"
			printf " ----------------------------------------------------  CRASResBill  ----------------------------------------------------------\n"
			printf "%-15s%10s%15s%18s%15s%12s%15s%12s%14s\n" \
				"bill_id"   "pay_acct_id"  "resource_id"  "default_acct_id"  "begin_date"   "end_date"   "current_date"   "waif_flag"   "region_code"
			printf " -----------------------------------------------------------------------------------------------------------------------------\n"
			grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%14d,%15d,%14d,%18d,%14d,%11d,%12d,%13d\n",$4,$3,$2,$5,$6,$7,$8,$9,$10}'
	fi


	if [ -f "tmp" ]; then
		rm tmp
	fi
	#===========================================================================================================================================
	#查询固废账单表
	for billID in $BillIDall
	do
	#	echo "billID="$billID
		mdb_client_ext -i $fileName -m $ipcfg  -d 0 >> tmp << CLIENTEOF
		select * from CRasRcBill where bill_id=$billID order by bill_id;
		exit;
CLIENTEOF
	done

	if [ -f "tmp" ];then
		printf " \n\n"
		printf " ----------------------------------------------------  CRASRcBill  ----------------------------------------------------------\n"
		printf "%-15s%8s%12s%14s%14s%14s%12s%14s%13s%13s%20s\n" \
		  "bill_id"   "product_id"  "price_id"  "item_code"  "primal_fee"   "primal_fee1"   "measure_id"   "billing_type"   "tax_include" "deduct_sts" "product_offering_id"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%12d,%14d,%13d,%11d,%12d,%14d,%12d,%15d,%12d,%15d\n",$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'

		rm tmp
	fi
	#==================================================================================================================================================
	#查询优惠账单表
	for billID in $BillIDall
	do
	#       echo $billID    
			mdb_client_ext -i $fileName -m $ipcfg  -d 0 >> tmp << CLIENTEOF
			select * from CRasPromBill where bill_id=$billID order by bill_id;
			exit;
CLIENTEOF
	done
	if [ -f "tmp" ];then
		printf " \n\n----------------------------------------------------  CRasPromBill  ----------------------------------------------------------\n"
		printf "%-10s%6s%16s%14s%10s%11s%12s%14s%15s%12s%11s%14s%13s%12s%20s\n" \
		 "bill_id" "product_id" "ref_product_id"  "ref_item_code"  "price_id" "base_item" "adjust_item" "discount_fee" "discount_fee1" \
		 "measure_id" "prom_flag" "billing_type"   "tax_include" "deduct_sts" "product_offering_id"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",\
		$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16}'

		rm tmp
	fi

	#================================================================================================================================================
	#查询话费账单表
	for billID in $BillIDall
	do
	#	   echo $billID    
			mdb_client_ext -i  $fileName -m $ipcfg -d 0 >> tmp << CLIENTEOF
			select * from CRasUsageBill where bill_id=$billID order by bill_id;
			exit;
CLIENTEOF
	done
	if [ -f "tmp" ];then
		printf " \n\n----------------------------------------------------  CRasUsageBill  ----------------------------------------------------------\n"
		printf "%-10s%6s%18s%18s%10s%11s%13s%14s%15s%18s%11s%14s%13s%20s\n" \
		 "bill_id" "product_id" "accumulate_value"  "accumulate_value1"  "item_code" "primal_fee" "discount_fee" "primal_fee1" "discount_fee1" \
		 "accu_measure_id" "measure_id" "billing_type"   "tax_include" "product_offering_id"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d \n",\
		$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}'

		rm tmp
	fi

	#================================================================================================================================================
	for billID in $BillIDall
	do
	#       echo $billID    
			mdb_client_ext -i  $fileName -m $ipcfg -d 0 >> tmp << CLIENTEOF
			select * from CRasDetachBill where bill_id=$billID order by bill_id;
			exit;
CLIENTEOF
	done
	if [ -f "tmp" ];then
			printf " \n\n----------------------------------------------------  CRasDetachBill  ----------------------------------------------------------\n"
			printf "%-15s%6s%15s%15s%15s%14s%15s%15s%15s%15s\n" \
			 "bill_id" "default_acct_id" "switch_res_id"  "resource_id"  "pay_acct_id" "begin_date" "end_date" "current_date" "waif_flag" \
			 "region_code"
			printf " -----------------------------------------------------------------------------------------------------------------------------\n"
			grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%-11d,%15d,%17d,%16d,%17d,%12d,%16d,%13d,%14d,%15d\n",\
			$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'

			rm tmp
	fi
	#=================================================================================================================================================
	if [ $Mode == 2 ];then
		mdb_client_ext -i  $fileName -m $ipcfg  -d 0 >> tmp << CLIENTEOF
		select * from CRasSpBill where acct_id=$ID order by acct_id;
		exit;
CLIENTEOF
	else
		mdb_client_ext -i  $fileName -m $ipcfg -d 0 >> tmp << CLIENTEOF
		select * from CRasSpBill where $VALUE=$ID order by acct_id;
		exit;
CLIENTEOF
	fi

	if [ -f "tmp" ];then
			printf " \n\n----------------------------------------------------  CRasSpBill  ----------------------------------------------------------\n"
			printf "%-12s%s%12s%10s%8s%10s%13s%12s%13s%10s%11s%8s%13s%13s%15s%13s%10s\n" \
			 "acct_id" "resource_id" "begin_date"  "end_date"  "sp_code" "oper_code" "service_code" "primal_fee" "primal_fee1" \
			 "item_code" "service_id" "dr_type"   "content_code" "measure_id" "billing_type" "tax_include" "fee_type"
			printf " -----------------------------------------------------------------------------------------------------------------------------\n"
			grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%d ,%d ,%d ,%d ,%s ,%s ,%s ,%d ,%d ,%d ,%d ,%d ,%s ,%d ,%d ,%d ,%d\n",\
			$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18}'

			rm tmp
	fi

	#===============================================================================================================================================
	if [ $Mode != 1 ];then
		mdb_client_ext -i  $fileName -m $ipcfg -d 0 >> tmp << CLIENTEOF
		select * from CRasAccBillDetail where acct_id=$ID order by acct_id;
		exit;
CLIENTEOF
	fi

	if [ -f "tmp" ];then
		printf " \n\n----------------------------------------------------  CRasAccBillDetail  ----------------------------------------------------------\n"
		printf "%-12s%s%12s%15s%13s%13s%15s%15s%15s%15s%15s%15s%15s%18s%20s%18s%13s%15s%10s%12s%13s\n" \
		 "acct_id" "begin_date"  "end_date"  "current_date" "item_code" "base_item" "adjust_item" "primal_fee" \
		 "cdr_discount" "discount_fee" "primal_fee1"   "cdr_discount1" "discount_fee1" "accumulate_value" "accumulate_value1" "accu_measure_id"\
		"measure_id" "billing_type" "fee_type" "prom_flag" "tax_include"
		printf " -----------------------------------------------------------------------------------------------------------------------------\n"
		grep "^[0-9]" tmp | sed -e "s/ //g" | awk -F',' '{printf "%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d ,%d\n",\
			$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15.$16,$17,$18,$19,$20,$21,$22}'

		rm tmp
	fi

done
