import datetime
import time

__author__ = 'Quiker'


def make_id(x):
    x._id = x.key.id()
    return x


def parse_datetime(date, format='%Y-%m-%dT%H:%M'):
    return struct_to_datetime(time.strptime(date, format))


def struct_to_datetime(t):
    return datetime.datetime(t.tm_year, t.tm_mon, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec)


epoch = lambda v: int(time.mktime(v.timetuple()))
to_int = lambda v: epoch(v) if isinstance(v, datetime.datetime) else v