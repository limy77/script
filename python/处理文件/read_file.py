#use like: python + script_name +  filename
# coding = utf-8

import  sys,os
try:
    filename=sys.argv[1]
    str_obrel = os.environ["OB_REL"]
    str_obsrc = os.environ["OB_SRC"]
    res_obrel = ""
    res_obsrc = ""
	str_all = ""
    try:
	
        f=open(filename)
    except IOError:
        print("ERROR:This is Files is not exist!!!")
        sys.exit()
    while True:
        line = f.readline()
		line = line.replace('\\',' ')
		line = line.strip()
		temp = ""
		if line not in str_all:
			str_all = str_all + line
			if os.path.islink(line):
				temp = os.readlink(line)
			else:
				temp = line
			if temp[-1].isalpha():
				line = line + ':'+ '0'
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
        if len(line) == 0:
            break
    f.close()
    res_obrel = res_obrel.replace(str_obrel,"OB_REL")
    res_obsrc = res_obsrc.replace(str_obsrc,"OB_SRC")
    print ("obrel:"+'\n'+ res_obrel)
    print ("obsrc:"+'\n'+ res_obsrc)
except IndexError:
    print(" 334 ")
