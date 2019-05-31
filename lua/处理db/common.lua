--[[this is a common file,defined basic functions--]]

mod     = math.mod;
substr  = string.sub;
floor   = math.floor;
ceil    = math.ceil;
getn    = table.getn;
setn    = table.setn;

--[[==================================================
--对象名称: Options
--作　　用: 攻取参数值
--function: Options.init (parameter);
--输入参数: parameter   [key:value;key:value];
--返回值　: boolean
--
--function: Options.get_opts(key);
--输入参数: key     字符型
--返回值　: 键值，若不存在返回nil
--================================================--]]
function Options()
    local m_table = {};

    local function init(parameter)
            if parameter ~= nil and string.len(parameter) ~= 0 then
                for k,v in string.gfind(parameter, "([%w_]+)%s*:%s*([%w_]+);*") do
                    m_table[k] = v;
                end;
            end;    
    end;

    local function get_opts(key)
        return m_table[key];
    end;

    return  {
                init     = init;
                get_opts = get_opts;
            } 
end;
    
--[[==================================================
--函数名称: add_month
--作    用: 返回n个月后的具体日期
--输入参数: 
--		1.YearMon	数值型
--		2.iMon			数值型
--输出参数: 无
--返 回 值: 返回iMon个月份后的日期
--==================================================--]]
function add_month(YearMon,iMon)
	local year = floor(YearMon/100);
	local mon = mod(YearMon,100);
	local afterDate = year*12+mon + iMon;
	if mod(afterDate,12) == 0 then
		local iYear = floor(afterDate/12)-1;
		local iMon  = 12;
		return iYear*100+iMon;
	else	
		return floor(afterDate/12)*100+ mod(afterDate,12);
	end;
end;

--[[==================================================
--函数名称: add_day
--作    用: 返回n个月后的具体日期
--输入参数: 
--		1.YearMonDay	数值型
--		2.nDays			数值型
--输出参数: 无
--返 回 值: 返回iDay个天数后的日期
--==================================================--]]
function add_day(YearMonDay,nDays)
    local monthDayA = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
    local monthDayB = {0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 };

    local monthDayAA = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    local monthDayBB = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    
	local year = floor(YearMonDay/10000);
    if(mod(year,4) == 0 and mod(year,100) ~= 0 or mod(year,400) == 0) then
        nDays = nDays + monthDayB[mod(YearMonDay/100,100)] + mod(YearMonDay,100);
    else
        nDays = nDays + monthDayA[mod(YearMonDay/100,100)] + mod(YearMonDay,100);
    end
    local yearDays
    if (mod(year,4) == 0 and mod(year,100) ~= 0 or mod(year,400) == 0) then
        yearDays = 366;
    else
        yearDays = 365;
    end
    if(nDays > 0) then
    
        while(nDays > yearDays)  do
        
            if (mod(year,4) == 0 and mod(year,100) ~= 0 or mod(year,400) == 0) then
                yearDays = 366;
            else
                yearDays = 365;
            end
            year = year + 1;
            nDays = nDays - yearDays;
        end
    
    else
    
        while(nDays <= 0 ) do
        
            year = year - 1;
            if (mod(year,4) == 0 and mod(year,100) ~= 0 or mod(year,400) == 0) then
                yearDays = 366;
            else
                yearDays = 365;
            end
            nDays = nDays + yearDays;
        end
    end
    local day=1;
    local month = 1;
    local pMonthDay ;
    if (yearDays == 365) then
        pMonthDay = monthDayAA;
    else
        pMonthDay = monthDayBB;
    end
    
    repeat
        day = pMonthDay[month];
        if(nDays > day) then        
            nDays = nDays - day;  
            month = month + 1;
        end
    until(nDays <= day)    

    return year * 10000 + month * 100 + nDays;
end;

--[[==================================================================
--函数名称: month_diff
--作    用: 返回两个日期段相差的月份
--输入参数: 
--			1.month1		起始日期(yyyymm)
--			2.month2		结束日期(yyyymm)
--输出参数: 无
--返 回 值: 返回两个日期段相差的月份
--================================================================--]]
function month_diff(month1,month2)
	local year1 = floor(month1/100);
	local year2 = floor(month2/100);
	local mon1	= mod(month1,100);
	local mon2	= mod(month2,100);
	return year1*12+mon1-year2*12-mon2;
end;  

--[[==================================================================
--函数名称: seconds_diff
--作    用: 返回两个日期之间差的秒数
--输入参数: 
--			1.month1		起始日期(yyyymmddhhmmss)
--			2.month2		结束日期(yyyymmddhhmmss)
--输出参数: 无
--返 回 值: 返回两个日期段相差的秒数
--================================================================--]]
function seconds_diff(month1,month2)
	local lmonth1 = tonumber(month1);
	local lmonth2 = tonumber(month2);




	return year1*12+mon1-year2*12-mon2;
end;  



--[[===================================================================
--函数名称: store_map
--作    用: 将sql语句检索的结果保存为table类型
--输入参数: 
--		1.strSel		sql语句
--		2.DBconn		数据库连接
--		3.key			构造table的key.可以是字符型,比如"serv_id"
--						,也可以是table型.比如{"serv_id","acct_id"}.
--		4.bOneFlag  标记key对应的记录是否是唯一的.
--输出参数: 无
--返 回 值: 返回一个table表,以key作为主键,如果key为nil,则返回一个数组
--===================================================================--]]
function store_map(strSel,DBconn,key,bOneFlag)

--key为table型时,采用此函数保存
	local function store_tabType(strSel,DBconn,key,bOneFlag)
	local tMetaCmp = {};
	local m_tMeta  = {};
	tMetaCmp = def_metaTab(key);
	m_tMeta.__index = function(tab,KEY)	
		local tCmpTab = tab._keyGether;
		setmetatable(KEY,tMetaCmp)
		local iLow = 1;
		local iHigh= getn(tCmpTab);
		while iLow <= iHigh do
			local iMid = floor((iLow+iHigh)/2);
			if tCmpTab[iMid] == KEY then
				return tab[tCmpTab[iMid]];
			elseif tCmpTab[iMid] < KEY then
				iLow = iMid +1;
			else
				iHigh = iMid - 1;
			end;
		end;
		return nil;
	end;			
	m_tMeta.__newindex = function(tab,KEY,val)
	error("attempt to update a readonly table");
	end;
----------------------------------------------------
	local get_tabKey = function (tabName,tabRec)
	    local iRec = getn(tabName);
	    local tabRst = {};
	    for i = 1,iRec,1 do
	        tabRst[tabName[i]] = tabRec[tabName[i]];
	    end;
	    return tabRst;
	end;
-----------------------------------------------------------
	local tabRst = {};
	local tTmpTot = {};
	local fdSel = potl.open(strSel,DBconn);
	local iNums = 1;
	while not potl.eof(fdSel) do
		local tabOneRec = potl.read(fdSel);
		setmetatable(tabOneRec,tMetaCmp);
		--table.insert(tTmpTot,tabOneRec);
		tTmpTot[iNums]=tabOneRec;
		iNums = iNums+1;
	end;
	potl.close(fdSel);
	--table.sort(tTmpTot);
	
	local tStKey = {}; --保存key
	local tKeyRec = 0;
	for i,v in ipairs(tTmpTot) do
	    local tabOneRec = tTmpTot[i];
	    local tmpKey = get_tabKey(key,tabOneRec); 
		setmetatable(tmpKey,tMetaCmp);
		if tKeyRec == 0 or tStKey[tKeyRec] ~= tmpKey then
			tKeyRec = tKeyRec + 1;
			tStKey[tKeyRec] = tmpKey;
		elseif tStKey[tKeyRec] == tmpKey then
			tmpKey = tStKey[tKeyRec];
		end;		   
	    if bOneFlag then
	        tabRst[tmpKey] = tabOneRec;
	    else
	        tabRst[tmpKey] = tabRst[tmpKey] or {};
	        table.insert(tabRst[tmpKey],tabOneRec);
	    end;
	end;
	tTmpTot = {};
	--table.sort(tStKey);			 
	tabRst._keyGether = tStKey;
	setmetatable(tabRst,m_tMeta);
	return tabRst;
	end;
--------------------------------------------------------------
--------------------------------------------------------------
	--存储key为非table型的数据
	local function store_otherType(strSel,DBconn,key,bOneFlag)
	local tabRst = {};
	local fdSel = potl.open(strSel,DBconn);
	while not potl.eof(fdSel) do
		local tOneRec = potl.read(fdSel);
		if key == nil then
			table.insert(tabRst,tOneRec);
		else
			local iRealKey = tOneRec[key];
			if bOneFlag then
				tabRst[iRealKey] = tOneRec;
			else
		        if  not tabRst[iRealKey] then
		            tabRst[iRealKey] = {};
		        end;
		        table.insert(tabRst[iRealKey],tOneRec);	
			end;
		end;
	end;
	potl.close(fdSel);
	return tabRst;
	end;

	-------------main section---------------------------------
	if type(key) == "table" then
		return store_tabType(strSel,DBconn,key,bOneFlag);
	else
		return store_otherType(strSel,DBconn,key,bOneFlag);
	end;

end;

--[[==================================================
--
--==================================================--]]
function CDealRec()
	local fd = 0;
	local function open(strSel,DBconn)	--打开一个sql语句句柄
		--log(strSel);
		fd = potl.open(strSel,DBconn);
	end;
	
	local function open_forins(strTabName,DBconn) --根据一个数据库表名,自动生成一个insert句柄
		fd = potl.open_forins(strTabName,DBconn);
	end;
	
	local function eof()			--判断记录集是否到底
		return potl.eof(fd);
	end;
	
	local function getOne()			--取得一行记录,放入一个table中
		return potl.read(fd);
	end;
	
	local function rewind()
		potl.rewind(fd);
	end;
	
	local function setOne(tabOneRec) --设置绑定变量到sql语句中,其中绑定变量以table形式存在
		potl.write(fd,tabOneRec);
	end;
	
	local function close()			--关闭打开的sql句柄.		
		potl.close(fd);
		fd = 0;
	end;
	
	return {open 	= open;
			open_forins = open_forins;
			eof 	= eof;
			getone 	= getOne;
			setone	= setOne;
			rewind	= rewind;
			close	= close
			};	
end;

--[[===============================================================
--函数名称: def_metaTab
--作    用: 定义一个内部表(metatable),供别的table来的引用,用于
--			table之间的比较大小
--输入参数: 
--			1.tcmpRule		比较规则,(table型)
--输出参数: 
--			无
--返 回 值: 无
--================================================================--]]
function def_metaTab(tcmpRule)
	local tRule = tcmpRule;
	local __lt = function(a,b)
	for i,v in ipairs(tRule) do	
		if a[v] < b[v] then
			return true; 
	    elseif a[v] > b[v] then 
	        return false;
	    end;
	end;
	return false;
	end;
	
	local __eq = function(a,b)
	for i,v in ipairs(tRule) do
	    if a[v] ~= b[v] then
	        return false;
	    end;            
	end;
	return true;
	end;
	return {__lt = __lt,__eq = __eq};
end;

--[[=============================================
--函数名称: get_seqVal
--作    用: 取得某个sequence的当前值
--输入参数: 
--			1.tcmpRule		比较规则,(table型)
--输出参数: 
--			无
--返 回 值: 返回一个闭函数.
--=============================================--]]
function get_seqVal(seqName,conName)
	local strTmp = "select "..seqName..".nextval val from dual";
	local fdTmp = potl.open(strTmp,conName);
	local function get_val()
		potl.rewind(fdTmp);
		local tTmp = potl.read(fdTmp);
		return tTmp.val;
	end;
	local function close()
		potl.close(fdTmp);
	end;
	return {get_val = get_val,close = close};
end;

--[[=============================================
--函数名称: get_dbLnk
--作    用: 取得远程数据链路值
--输入参数: 
--			1.lnkName		指定的数据链路名称,(string型)
--			2.conName		数据库连接对象
--输出参数: 
--			无
--返 回 值: 返回数据链路的具体值
--=============================================--]]
function get_dbLnk(lnkName,conName)
	local strSql = "select para_value from accp_sys_para where para_name = '"..lnkName.."'";
	local fd = potl.open(strSql,conName);
	if not potl.eof(fd) then
		local tTmp = potl.read(fd);
		potl.close(fd);
		if tTmp.para_value ~= nil then
			return "@"..tTmp.para_value;
		else
			return "";
		end;
	end;
	potl.close(fd);
end;
    
--====================================
--写任务表的类
--====================================
function CTask()

	local m_billMon			= nil;
	local m_region			= nil;
	local m_cond			= nil;
	local m_zcConn			= nil;
	local m_moduName		= nil;
	local m_cUpTask			= CDealRec();
	local m_iBatchID		= 0;
	--初始化	
	local function open(billmonth,region,condition,zcConn,modulename)
			m_billMon 	= billmonth;
			m_region	= region;
			m_cond		= condition;
			m_zcConn	= zcConn;
			m_moduName	= modulename;
	end;
	
	--判断是否已经处理过了,返回-1表示已经处理完毕.
	local function is_done()
		
		local iRet = 0;
		local fget_batchID = get_seqVal("accp_seq_task_prg",m_zcConn);
		m_iBatchID	= fget_batchID.get_val();
		fget_batchID.close();
		
		local strSql = "select batch_id,nvl(bill_count,0) bill_count,nvl(proc_sts,0) proc_sts"
		strSql=strSql.." from accp_task_prg ";
		strSql=strSql.." where module_name = 'luaexec("..m_moduName..")' ";
		strSql=strSql.." and prg_type = 2 and task_key1 = '"..tostring(m_region).."-"..m_cond.."'";
		strSql=strSql.." and cur_task_num = -1 and task_key = "..tostring(m_billMon);
		local cTmpProc = CDealRec();
		cTmpProc.open(strSql,m_zcConn);
		if cTmpProc.eof() then
			cTmpProc.close();
			local str = "insert into accp_task_prg"
			str=str.."(batch_id,prg_type,task_key,task_key1,cur_task_num,cur_subtask_num,begin_time,end_time,module_name,bill_count,proc_sts)"
			str=str.." values("..tostring(m_iBatchID)..",2,"..tostring(m_billMon)..",'"..tostring(m_region).."-"..m_cond.."'";
			str=str..",-1,-1,sysdate,sysdate,'luaexec("..m_moduName..")',0,3)";
			cTmpProc.open(str,m_zcConn);
			potl.commit(m_zcConn);
			cTmpProc.close();
				iRet = 0;
		else
		   local tRec = cTmpProc.getone();
		   cTmpProc.close();
		   m_iBatchID = tRec.batch_id;
		   if tRec.proc_sts == 2 then
		   		iRet = -1;
		   else
		   		iRet = tRec.bill_count;
		   end;
		end;
		
		if iRet ~= -1 then
			--更新任务表中的断点
			local strUpTask = "update accp_task_prg set end_time = sysdate,"
			strUpTask=strUpTask.."bill_count = :serv_id<double>,proc_sts=:proc_sts<short>";
			strUpTask=strUpTask.." where batch_id = "..tostring(m_iBatchID);
			m_cUpTask.open(strUpTask,m_zcConn);		
		end;
		return iRet;
	end;	
	
	--更新任务接口表记录
	local function log_rec(serv_id,sts)
		local tRec = {};
		tRec.serv_id = serv_id;
		tRec.proc_sts = sts;
		m_cUpTask.setone(tRec);
	end;
	
	--清空任务表
	local function clear()
		local tTmp = CDealRec();
		local str = "delete from accp_task_prg where batch_id = "..tostring(m_iBatchID);
		tTmp.open(str,m_zcConn);
		potl.commit(m_zcConn);
		tTmp.close();
	end;
		
	--关闭内部打开的流
	local function close()
		m_cUpTask.close();
	end;	
	
	return {
			open 		= open;
			is_done = is_done;
			log_rec	= log_rec;
			clear	= clear;
			close		= close;
		   };
					
end;    

--[[======================================
--函数名称:exec_sql
--作    用:直接执行没有绑定变量的sql语句
--输入参数: 1.sql语句 2.数据库连接描述符
--输出参数:无
--======================================--]]
function exec_sql(sqlstatement,DBconn)
		log(sqlstatement);
        local tmpf = potl.open(sqlstatement,DBconn);
        potl.commit(DBconn);
        potl.close(tmpf);
end;

--[[======================================
--函数名称:judge_tabExists
--作    用:根据输入的表名和连接判断指定的表名是否存在。
--输入参数: 1.tablename    原表名 
            2.connDesc     目标连接
--输出参数: 无
--返回值： boolen类型
--======================================--]]
function judge_tabExists(tabname,connDesc)
	local sql = "select * from sys.tab where tname = upper('"..tabname.."')";
	local cTmp = CDealRec();
	cTmp.open(sql,connDesc);
	local bRst = false;
	if not cTmp.eof() then
		bRst = true;
	end;
	cTmp.close();	
	return bRst;
end;

--[[=====================================================
--函数名称:copy_dbTable
--作    用:将表从srcConnDesc的地方拷贝到dstConnDesc下面
--输入参数: 1.tablename    原表名 
--			2.qryCond	   查询条件
--          3.srcConnDesc  源连接句柄
--			4.dstConnDesc  目标连接句柄
--输出参数: 无
--返回值： 无
--=========================================================--]]
function copy_dbTable(srcTabName,qryCond,srcConnDesc,dstTabName,dstConnDesc)
	if judge_tabExists(dstTabName,dstConnDesc) then
		local strDrop = "drop table "..dstTabName;
		exec_sql(strDrop,dstConnDesc);
	end;
	
	local strCrt = "create table "..dstTabName.."(";
	local strView = "select column_name,data_type,data_length,nvl(data_precision,0) data_precision ,nvl(data_scale,0) data_scale,nullable";
	strView = strView.." from user_tab_columns ";
	strView = strView.." where table_name = upper('"..srcTabName.."')";
	strView = strView.." order by column_id ";
	local cTmpSel = CDealRec();
	cTmpSel.open(strView,srcConnDesc);
	if cTmpSel.eof() then
		error("no such table "..srcTabName);
	end;
	
	while not cTmpSel.eof() do
		local tRec = cTmpSel.getone();
		strCrt = strCrt..tRec.column_name.." "..tRec.data_type;
		if tRec.data_type == "NUMBER" then
			if tRec.data_precision ~= 0 then
				strCrt = strCrt.."("..tRec.data_precision;
				if tRec.data_scale ~= 0 then
					strCrt = strCrt..","..tRec.data_scale;
				end;
				strCrt = strCrt..")";
			end;
		elseif tRec.data_type == "VARCHAR2" or tRec.data_type == "CHAR" then
			strCrt = strCrt.."("..tRec.data_length..")";
		elseif tRec.data_type == "DATE" then
			strCrt = strCrt.."";
		else
			error("unknown data type ");
		end;
		
		--判断是否允许为空
		if tRec.nullable == 'N' then
			strCrt = strCrt.." not null ";
		end;
		strCrt = strCrt..",\n";
	end;
	cTmpSel.close();
	
	strCrt = string.sub(strCrt,1,-3);
	strCrt = strCrt..")";
	log(strCrt);
	exec_sql(strCrt,dstConnDesc);
	
	local cTmpIns = CDealRec();
	local cTmpSelSrc = CDealRec();
	cTmpIns.open_forins(dstTabName,dstConnDesc);
	
	local strSelSrc = "select * from "..srcTabName;
	if qryCond ~= "" then
		strSelSrc = strSelSrc.." where "..qryCond;
	end;
	cTmpSelSrc.open(strSelSrc,srcConnDesc);
	while not cTmpSelSrc.eof() do
		local tRec = cTmpSelSrc.getone();
		cTmpIns.setone(tRec);
	end;
	potl.commit(dstConnDesc);
	cTmpIns.close();
	cTmpSelSrc.close();
end;
	

