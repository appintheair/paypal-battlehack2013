from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import datetime
import smtplib
import time

EMAIL_FROM = 'bayram.annakov@gmail.com'
SENDGRID_USERNAME = 'bayramannakov'
SENDGRID_PASSWORD = ',fqrf13@fgcd'


def make_id(x):
    x._id = x.key.id()
    return x


def parse_datetime(date, format='%Y-%m-%dT%H:%M'):
    return struct_to_datetime(time.strptime(date, format))


def struct_to_datetime(t):
    return datetime.datetime(t.tm_year, t.tm_mon, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec)


epoch = lambda v: int(time.mktime(v.timetuple()))
to_int = lambda v: epoch(v) if isinstance(v, datetime.datetime) else v


def send_email(donation, donator):
    msg = MIMEMultipart('alternative')
    msg['Subject'] = 'Donation raised successfully'
    msg['From'] = EMAIL_FROM
    msg['To'] = donator.email

    text = 'Donation %s was raised successfully! \nThank you sooo much!\n' % donation.title

    msg.attach(MIMEText(text, 'plain'))

    s = smtplib.SMTP('smtp.sendgrid.net', 587)
    s.login(SENDGRID_USERNAME, SENDGRID_PASSWORD)
    s.sendmail(EMAIL_FROM, donator.email, msg.as_string())

    s.quit()