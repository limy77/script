#use like: python + script_name +  libname
# coding = utf-8

import  sys,os
try:
    	str_obrel = os.environ["OB_REL"]
    	lib_name=sys.argv[1]
	str_order = "ldd   "+ lib_name
	res_obrel = ""
   	try:
		f = os.popen(str_order)
    	except:
		print ("you need checke the order" + str_order+" whether it can do well in the linux")
		sys.exti(1)
   	lines = f.readlines()
    	temp = ""
    	for line in lines:
		if  str_obrel not in line :
			continue
        	l_index = line.find('>')
		r_index = line.find('(')
		if l_index == -1 or  r_index == -1 :
			continue
		l_index = l_index + 1
		line = line[l_index:r_index].strip()
#		print ('line:'+ line)
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
		res_obrel = res_obrel + line +'\n'
	res_obrel = res_obrel.replace(str_obrel,"OB_REL")
	print ("res_obrel:"+'\n'+ res_obrel)
except IndexError:
    print(" 334 ")

