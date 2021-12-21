#!/usr/bin/env python3

PREFIX = ' '

import datetime

now = datetime.datetime.now()
minutes = now.hour * 60 + now.minute
percentage = round(minutes * 100 / 1440)

print(PREFIX + str(percentage) + "%")
