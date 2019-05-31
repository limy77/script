--[[=====================================================
-- 文件名称: sql.lua
-- 功　　能: 
-- 当前版本: v1.0
-- 传参接口的定义;
	Main( v8_db,v5_db)


--===================================================--]]

function action()
	local m_v5Conn = nil;				--V5域链接
	local m_yearMonth = nil;			--年月,格式yyyymm
	local m_V8Conn = nil;				--V8域链接
	local m_valid_date = nil;			
	local m_expire_date = nil;
	local m_systime = nil;				--获取的系统时间 格式yyyymmDDHHMMSS
	local m_acctId = nil;
	local m_regionCode = nil;
	local m_v8_db = nil;
	local m_v5_db = nil;
	function init (v8_db,v5_db)
		log("enter  init  function!");
		m_v5_db = v5_db;
		m_v8_db = v8_db;
		log("m_v8_db:"..m_v8_db);
		log("m_v5_db:"..m_v5_db);
		m_V8Conn = potl.get_connect(m_v8_db);	--取得到V8环境下用户连接
		getsysdate(m_V8Conn);
		m_yearMonth = string.sub(m_systime,1,6);
		log("m_yearMonth:"..m_yearMonth);
		deal();
		
		log("leave  init  function!");
	end
	--获取acctid
	function deal()
		log("enter  deal  function!");
		--local servId = nil;
		for x = 0,9 do 
			getsysdate(m_V8Conn);
			log("m_systime:"..m_systime);
			local sql =   " select t1.ACCT_ID as acct_id, t1.RESOURCE_ID as ser_id from ad.ca_account_res_"..x.." t1,cd.co_prod_"..x
						.." t2,cd.cm_resource_"..x .." t3 where t1.RESOURCE_ID = t2.OBJECT_ID "
						.."	and t2.OBJECT_ID=t3.RESOURCE_ID and t3.brand_id=7"
						.." and t2.PRODUCT_OFFERING_ID = 85410013 and"
						.." t2.PROD_VALID_DATE <  to_date('" ..m_systime.. "' ,'yyyy-mm-dd hh24 mi ss')"
						.."	and t2.PROD_EXPIRE_DATE  > to_date('" ..m_systime.. "' ,'yyyy-mm-dd hh24 mi ss')"
						.." and t1.ACCT_ID = 101944670"
			log("sql:"..sql);
			local sqldealRec = CDealRec();
			sqldealRec.open(sql,m_V8Conn);
			while not sqldealRec.eof() do
				local tRec = sqldealRec.getone();
				m_acctId = tRec.acct_id;
				
				local servId = tonumber(tRec.ser_id);
				m_regionCode = math.mod(servId, 10) + 101;
				potl.off_connect(m_V8Conn);
				m_v5Conn = potl.get_connect(m_v5_db);
				get_valid_expire_date();
				
			end;
		end
	log("leave  deal  function!");
	end

	--将数据插入表，并更新表
	function deal_db()
		log("enter  deal_db  function!");
		
		--现获取字段SO_NBR值
		local vSequence = " ";
		local sql = "select zg.sid.nextval  from SYS.Dual"
		log("sql:"..sql);
		local fdTmp = potl.open(sql,m_v5Conn);
		local tTmp = potl.read(fdTmp);
		vSequence = tTmp.nextval;
		vSequence = m_yearMonth..vSequence;
		log("vSequence:"..vSequence);
		
		--插入表zg.acc_intellnet_reg_xxxxYYYYMM 中
		local Insert_sql = "INSERT INTO zg.acc_intellnet_reg_0"..m_regionCode..m_yearMonth
						 .." (SO_NBR,ACCT_ID,PVALID_DATE,PEXPIRE_DATE,NVALID_DATE,NEXPIRE_DATE) VALUES("
						 ..vSequence..","..m_acctId..",TO_DATE('"..m_valid_date.."', 'yyyy-mm-dd hh24 mi ss'),TO_DATE('"
						 ..m_expire_date.."', 'yyyy-mm-dd hh24 mi ss'),TO_DATE('"..m_valid_date.."', 'yyyy-mm-dd hh24 mi ss'),TO_DATE('2030-01-01', 'yyyy-mm-dd'))";
	
		log("Insert_sql:"..Insert_sql);
		exec_sql(Insert_sql,m_v5Conn);
		
		--更新表acc_intellnet_user_cycle的字段
		local update_sql = "UPDATE zg.acc_intellnet_user_cycle t SET t.expire_date = TO_DATE('2030-01-01',"
		.." 'yyyy-mm-dd'),t.balance_expire_date = TO_DATE('2030-01-01','yyyy-mm-dd') WHERE t.acct_id = " ..m_acctId ;
		log("update_sql:"..update_sql);
		exec_sql(update_sql,m_v5Conn);

		potl.off_connect(m_v5Conn);
		log("leave  deal_db  function!");
	end
	
	--获取生失效时间，并调用insert_db()函数插入到和更新
	function get_valid_expire_date()
		log("enter  get_valid_expire_date  function!");
		local sql = "SELECT t3.valid_date, t3.expire_date  from zg.acc_intellnet_user_cycle t3 "..
					" where t3.acct_id =  "..m_acctId.."  AND t3.sts=0"
		log("sql:"..sql);
		local sqldealRec = CDealRec();
		sqldealRec.open(sql,m_v5Conn);
		while not sqldealRec.eof() do
			local tRec = sqldealRec.getone();
			m_valid_date = tRec.valid_date;
			m_expire_date = tRec.expire_date;
			deal_db();
		end;
		
		log("leave  get_valid_expire_date  function!");
	end
	
	--获取系统时间
	function getsysdate(db_Conn)
		log("enter  getsysdate  function!");
		local sql = "select sysdate from sys.dual"
		log("sql:"..sql);
		local sqldealRec = CDealRec();
		sqldealRec.open(sql,db_Conn);
		while not sqldealRec.eof() do
			local tRec = sqldealRec.getone();
			m_systime = tRec.sysdate;
		end;
		sqldealRec.close();
		log("leave  getsysdate  function!");
	end

	return {
			init = init;
		};
end

function main(
			 v8_db,			--V8db
			 v5_db  		--v5db
			 )
	require ("common");
	log("enter lua !");
	
	local m_action = action();
	m_action.init(v8_db,v5_db);
	log("leave  lua!")
end
