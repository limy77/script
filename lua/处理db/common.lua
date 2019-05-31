--[[this is a common file,defined basic functions--]]

mod     = math.mod;
substr  = string.sub;
floor   = math.floor;
ceil    = math.ceil;
getn    = table.getn;
setn    = table.setn;

--[[==================================================
--��������: Options
--��������: ��ȡ����ֵ
--function: Options.init (parameter);
--�������: parameter   [key:value;key:value];
--����ֵ��: boolean
--
--function: Options.get_opts(key);
--�������: key     �ַ���
--����ֵ��: ��ֵ���������ڷ���nil
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
--��������: add_month
--��    ��: ����n���º�ľ�������
--�������: 
--		1.YearMon	��ֵ��
--		2.iMon			��ֵ��
--�������: ��
--�� �� ֵ: ����iMon���·ݺ������
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
--��������: add_day
--��    ��: ����n���º�ľ�������
--�������: 
--		1.YearMonDay	��ֵ��
--		2.nDays			��ֵ��
--�������: ��
--�� �� ֵ: ����iDay�������������
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
--��������: month_diff
--��    ��: �����������ڶ������·�
--�������: 
--			1.month1		��ʼ����(yyyymm)
--			2.month2		��������(yyyymm)
--�������: ��
--�� �� ֵ: �����������ڶ������·�
--================================================================--]]
function month_diff(month1,month2)
	local year1 = floor(month1/100);
	local year2 = floor(month2/100);
	local mon1	= mod(month1,100);
	local mon2	= mod(month2,100);
	return year1*12+mon1-year2*12-mon2;
end;  

--[[==================================================================
--��������: seconds_diff
--��    ��: ������������֮��������
--�������: 
--			1.month1		��ʼ����(yyyymmddhhmmss)
--			2.month2		��������(yyyymmddhhmmss)
--�������: ��
--�� �� ֵ: �����������ڶ���������
--================================================================--]]
function seconds_diff(month1,month2)
	local lmonth1 = tonumber(month1);
	local lmonth2 = tonumber(month2);




	return year1*12+mon1-year2*12-mon2;
end;  



--[[===================================================================
--��������: store_map
--��    ��: ��sql�������Ľ������Ϊtable����
--�������: 
--		1.strSel		sql���
--		2.DBconn		���ݿ�����
--		3.key			����table��key.�������ַ���,����"serv_id"
--						,Ҳ������table��.����{"serv_id","acct_id"}.
--		4.bOneFlag  ���key��Ӧ�ļ�¼�Ƿ���Ψһ��.
--�������: ��
--�� �� ֵ: ����һ��table��,��key��Ϊ����,���keyΪnil,�򷵻�һ������
--===================================================================--]]
function store_map(strSel,DBconn,key,bOneFlag)

--keyΪtable��ʱ,���ô˺�������
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
	
	local tStKey = {}; --����key
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
	--�洢keyΪ��table�͵�����
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
	local function open(strSel,DBconn)	--��һ��sql�����
		--log(strSel);
		fd = potl.open(strSel,DBconn);
	end;
	
	local function open_forins(strTabName,DBconn) --����һ�����ݿ����,�Զ�����һ��insert���
		fd = potl.open_forins(strTabName,DBconn);
	end;
	
	local function eof()			--�жϼ�¼���Ƿ񵽵�
		return potl.eof(fd);
	end;
	
	local function getOne()			--ȡ��һ�м�¼,����һ��table��
		return potl.read(fd);
	end;
	
	local function rewind()
		potl.rewind(fd);
	end;
	
	local function setOne(tabOneRec) --���ð󶨱�����sql�����,���а󶨱�����table��ʽ����
		potl.write(fd,tabOneRec);
	end;
	
	local function close()			--�رմ򿪵�sql���.		
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
--��������: def_metaTab
--��    ��: ����һ���ڲ���(metatable),�����table��������,����
--			table֮��ıȽϴ�С
--�������: 
--			1.tcmpRule		�ȽϹ���,(table��)
--�������: 
--			��
--�� �� ֵ: ��
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
--��������: get_seqVal
--��    ��: ȡ��ĳ��sequence�ĵ�ǰֵ
--�������: 
--			1.tcmpRule		�ȽϹ���,(table��)
--�������: 
--			��
--�� �� ֵ: ����һ���պ���.
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
--��������: get_dbLnk
--��    ��: ȡ��Զ��������·ֵ
--�������: 
--			1.lnkName		ָ����������·����,(string��)
--			2.conName		���ݿ����Ӷ���
--�������: 
--			��
--�� �� ֵ: ����������·�ľ���ֵ
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
--д��������
--====================================
function CTask()

	local m_billMon			= nil;
	local m_region			= nil;
	local m_cond			= nil;
	local m_zcConn			= nil;
	local m_moduName		= nil;
	local m_cUpTask			= CDealRec();
	local m_iBatchID		= 0;
	--��ʼ��	
	local function open(billmonth,region,condition,zcConn,modulename)
			m_billMon 	= billmonth;
			m_region	= region;
			m_cond		= condition;
			m_zcConn	= zcConn;
			m_moduName	= modulename;
	end;
	
	--�ж��Ƿ��Ѿ��������,����-1��ʾ�Ѿ��������.
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
			--����������еĶϵ�
			local strUpTask = "update accp_task_prg set end_time = sysdate,"
			strUpTask=strUpTask.."bill_count = :serv_id<double>,proc_sts=:proc_sts<short>";
			strUpTask=strUpTask.." where batch_id = "..tostring(m_iBatchID);
			m_cUpTask.open(strUpTask,m_zcConn);		
		end;
		return iRet;
	end;	
	
	--��������ӿڱ��¼
	local function log_rec(serv_id,sts)
		local tRec = {};
		tRec.serv_id = serv_id;
		tRec.proc_sts = sts;
		m_cUpTask.setone(tRec);
	end;
	
	--��������
	local function clear()
		local tTmp = CDealRec();
		local str = "delete from accp_task_prg where batch_id = "..tostring(m_iBatchID);
		tTmp.open(str,m_zcConn);
		potl.commit(m_zcConn);
		tTmp.close();
	end;
		
	--�ر��ڲ��򿪵���
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
--��������:exec_sql
--��    ��:ֱ��ִ��û�а󶨱�����sql���
--�������: 1.sql��� 2.���ݿ�����������
--�������:��
--======================================--]]
function exec_sql(sqlstatement,DBconn)
		log(sqlstatement);
        local tmpf = potl.open(sqlstatement,DBconn);
        potl.commit(DBconn);
        potl.close(tmpf);
end;

--[[======================================
--��������:judge_tabExists
--��    ��:��������ı����������ж�ָ���ı����Ƿ���ڡ�
--�������: 1.tablename    ԭ���� 
            2.connDesc     Ŀ������
--�������: ��
--����ֵ�� boolen����
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
--��������:copy_dbTable
--��    ��:�����srcConnDesc�ĵط�������dstConnDesc����
--�������: 1.tablename    ԭ���� 
--			2.qryCond	   ��ѯ����
--          3.srcConnDesc  Դ���Ӿ��
--			4.dstConnDesc  Ŀ�����Ӿ��
--�������: ��
--����ֵ�� ��
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
		
		--�ж��Ƿ�����Ϊ��
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
	

