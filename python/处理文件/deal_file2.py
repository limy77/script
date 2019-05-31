#use like: python + script_name +  filename
# coding = utf-8
    
import  sys,os
try:
    filename=sys.argv[1]
    str_obrel = os.environ["OB_REL"]
    str_obsrc = os.environ["OB_SRC"]
    str_billing = "balance_billing/billing"
    str_balance = "balance_billing/balance"
    num_balance = ""
    num_billing = ""    
    res_obrel = ""
    res_obsrc = ""
    str_all = ""
    try:
        f=open(filename)
        f_txt = open("/home/adci_rdcm/adci/brc/develop/oblog/commitid_list.txt")
    except IOError:
        print("ERROR:This is Files is not exist!!!")
        
    lines = f.readlines()
    lines_txt = f_txt.readlines()
    for line_txt in lines_txt:
	list_str = line_txt.split(':')
	print (list_str)
        if "balance" == list_str[0].strip():
            num_balance = list_str[1].strip()
        if "billing" == list_str[0].strip():
            num_billing = list_str[1].strip()
		
    for line in lines:
        line = line.replace('\\',' ')
        line = line.strip()
        temp = ""
        if line not in str_all:
            str_all = str_all + line
            if os.path.islink(line):
                temp = os.readlink(line)
            else:
                temp = line
            if temp[-1].isalpha() :
                if str_obrel in temp:
                    line = line + ':'+ '0'
                if str_obsrc  in temp:
                    if str_billing  in temp:
                        line = line + ':'+  num_billing
                    if str_balance  in temp:
                        line = line + ':'+  num_balance

            else:
                index = temp.find('.')
                index = index + 1
                index = temp.find('.',index)
                index = index + 1
                line = line + ':' + temp[index::]
            if str_obrel in line:
                res_obrel = res_obrel + line +'\n'
            if str_obsrc in line:   
                res_obsrc = res_obsrc + line +'\n'

    f.close()
    res_obrel = res_obrel.replace(str_obrel,"OB_REL")
    res_obsrc = res_obsrc.replace(str_obsrc,"OB_SRC")
    print ("obrel:"+'\n'+ res_obrel)
    print ("obsrc:"+'\n'+ res_obsrc)
except IndexError:
    print(" 334 ")
