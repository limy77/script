# -*- coding:utf-8 -*-
# __author__ = 'justing'
 
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
 
SENDER = "xxx@qq.com"
PASSWD = "xxx"--授权码
SMTPSERVER = "smtp.qq.com"
 
class Mail(object):

    def __init__(self,  receivers, subject, content, content_type=None, attachment=None, sender=SENDER, passwd=PASSWD,
        smtp_server=SMTPSERVER):
        self.sender = sender
        self.passwd = passwd
        self.smtp_server = smtp_server
        #receivers type list
        self.receivers = receivers
        self.subject = subject
        self.content = content
        self.content_type = content_type
        #attachement type is list or str
        self.attachment = attachment
 
 
    def attach(self, path):
        filename = os.path.basename(path)
        with open(path, 'rb') as f:
            info = f.read()
        attach_part = MIMEApplication(info)
        attach_part.add_header('Content-Disposition', 'attachment', filename=filename)
        self.msg.attach(attach_part)
 
    def handle_attachment(self):
        if isinstance(self.attachment, list):
            for path in self.attachment:
                self.attach(path)
        if isinstance(self.attachment, str):
            self.attach(path)
 
    def handle(self):
 
        if not self.content_type or self.content_type == "text":
            text = MIMEText(self.content, 'plain', 'utf-8')
            
        elif self.content_type == "html":
            text = MIMEText(self.content, _subtype='html', _charset='utf-8')
        else:
            raise "type only support utf and text"
        self.msg.attach(text)
        if self.attachment:
            self.handle_attachment()
 
    def send(self):
        self.msg = MIMEMultipart()
        self.msg['From'] = self.sender
        self.msg['To'] = ','.join(self.receivers)
        self.msg['Subject'] = self.subject
        self.handle()
 
        try:
            server = smtplib.SMTP(self.smtp_server)
            #server.set_debuglevel(1)
            server.ehlo()
            server.starttls()
            server.login(self.sender, self.passwd)
            #self.receivers type list
            server.sendmail(self.sender, self.receivers, self.msg.as_string())
            server.quit()
        except Exception, e:
            print "fail to send mail:{}".format(e)
 
 
 
receivers = ['xxx@qq.com']
subject = "FROM CENTOS7"
content = "files as follows"
content_type = "text"
path = r"./"
attachment = []
for parent_dir, child_dirs, filenames in os.walk(path):
    print "parent_dir>>", parent_dir
    print "filenames", filenames

    for filename in filenames:
        attachment.append(os.path.join(parent_dir, filename))
 
mail = Mail(receivers, subject, content, content_type, attachment)
mail.send()
